// ========== PRODUCT_MANAGER.DART - Lista de produtos ==========
// Escuta Firestore em tempo real. Filtra por busca. ChangeNotifier.

import 'dart:async'; // StreamSubscription

import 'package:cloud_firestore/cloud_firestore.dart'; // FirebaseFirestore, QuerySnapshot, FirebaseException
import 'package:flutter/material.dart'; // ChangeNotifier, debugPrint
import 'package:lojavirtual/models/product.dart'; // Product

class ProductManager extends ChangeNotifier {
  // Notifica UI quando produtos ou busca mudam
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instância do Firestore
  static const String productsCollection =
      'products'; // Nome da coleção no Firestore

  bool _loading = false; // true enquanto carrega
  String? _error; // Mensagem de erro ou null
  bool get loading => _loading;
  String? get error => _error;

  StreamSubscription<QuerySnapshot>?
  _productsSub; // Inscrição no stream (para cancelar no dispose)

  ProductManager() {
    _listenToProducts(); // Inicia escuta ao criar o ProductManager
  }

  List<Product> _allProducts = []; // Lista completa (sem filtro)
  List<Product> get allProducts => List<Product>.unmodifiable(
    _allProducts,
  ); // Cópia imutável (não alterável)

  String _search = ''; // Texto digitado na busca
  String get search => _search;
  set search(String value) {
    if (_search == value) return;
    _search = value;
    notifyListeners(); // Atualiza UI (filteredProducts muda)
  }

  List<Product> get filteredProducts {
    // Lista filtrada pelo texto de busca
    final s = _search.trim().toLowerCase(); // Remove espaços, minúsculo
    if (s.isEmpty) return allProducts; // Busca vazia = mostra todos
    return List<Product>.unmodifiable(
      _allProducts.where(
        (p) => p.name.toLowerCase().contains(s),
      ), // Filtra: nome contém o texto
    );
  }

  void _setLoading(bool v) {
    if (_loading == v) return;
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    if (_error == msg) return;
    _error = msg;
    notifyListeners();
  }

  void _listenToProducts() {
    // Escuta coleção 'products' em tempo real
    _setLoading(true);
    _setError(null);
    _productsSub
        ?.cancel(); // Cancela inscrição anterior (evita múltiplas escutas)
    _productsSub = firestore
        .collection(productsCollection)
        .snapshots()
        .listen(
          (snapshot) {
            // Callback quando dados mudam no Firestore
            _allProducts = snapshot.docs
                .map((d) => Product.fromDocument(d))
                .toList(); // Converte docs em Product
            _setError(null);
            _setLoading(false);
          },
          onError: (e, st) {
            debugPrint('[ProductManager] Erro: $e'); // Log no console
            if (e is FirebaseException && e.code == 'permission-denied') {
              // Sem permissão nas Rules
              _allProducts = [];
              _setError(
                'Sem permissão para ler "$productsCollection". Ajuste as Rules do Firestore.',
              );
              _productsSub?.cancel();
              _productsSub = null; // Para de escutar
            } else {
              _setError('Erro ao carregar produtos: $e');
            }
            _setLoading(false);
          },
        );
  }

  void retry() =>
      _listenToProducts(); // Botão "Tentar novamente" na tela de erro

  Product? findProductById(String id) {
    final query = id.trim();
    if (query.isEmpty) return null;

    try {
      return _allProducts.firstWhere((p) => p.id == query);
    } on StateError {
      final lower = query.toLowerCase();
      try {
        return _allProducts.firstWhere((p) => p.id.toLowerCase() == lower);
      } on StateError {
        final canonical = _normalizeLikelyTypedId(query);
        try {
          return _allProducts.firstWhere(
            (p) => _normalizeLikelyTypedId(p.id) == canonical,
          );
        } on StateError {
          return null;
        }
      }
    }
  }

  Product? findProductByName(String name) {
    final query = name.trim().toLowerCase();
    if (query.isEmpty) return null;

    try {
      return _allProducts.firstWhere((p) => p.name.trim().toLowerCase() == query);
    } on StateError {
      final normalizedQuery = _normalizeTextToken(query);
      try {
        return _allProducts.firstWhere(
          (p) => _normalizeTextToken(p.name) == normalizedQuery,
        );
      } on StateError {
        return null;
      }
    }
  }

  Future<Product?> findProductByReference(String reference) async {
    final query = reference.trim();
    if (query.isEmpty) return null;

    final localById = findProductById(query);
    if (localById != null) return localById;

    final localByName = findProductByName(query);
    if (localByName != null) return localByName;

    try {
      return _allProducts.firstWhere(
        (p) => p.images.any((image) => image.trim() == query),
      );
    } on StateError {
      // segue para buscas remotas
    }

    try {
      final docId = _extractProductId(query);
      final doc = await firestore.collection(productsCollection).doc(docId).get();
      if (doc.exists) {
        return Product.fromDocument(doc);
      }
    } on FirebaseException {
      // fallback para busca por nome
    }

    try {
      final byName = await firestore
          .collection(productsCollection)
          .where('name', isEqualTo: query)
          .limit(1)
          .get();
      if (byName.docs.isNotEmpty) {
        return Product.fromDocument(byName.docs.first);
      }
    } on FirebaseException {
      // mantém retorno nulo para o caller tratar
    }

    try {
      final byImage = await firestore
          .collection(productsCollection)
          .where('images', arrayContains: query)
          .limit(1)
          .get();
      if (byImage.docs.isNotEmpty) {
        return Product.fromDocument(byImage.docs.first);
      }
    } on FirebaseException {
      // mantém retorno nulo para o caller tratar
    }

    return null;
  }

  String _extractProductId(String raw) {
    final normalized = raw.trim();
    if (normalized.contains('/')) {
      final parts = normalized.split('/').where((p) => p.trim().isNotEmpty).toList();
      if (parts.isNotEmpty) return parts.last.trim();
    }
    return normalized;
  }

  String _normalizeTextToken(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizeLikelyTypedId(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[il|]'), '1')
        .replaceAll('o', '0');
  }

  @override
  void dispose() {
    _productsSub?.cancel(); // Cancela stream (evita memory leak)
    super.dispose();
  }
}
