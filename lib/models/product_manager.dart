// ========== PRODUCT_MANAGER.DART - Lista de produtos ==========
// Escuta Firestore em tempo real. Filtra por busca. ChangeNotifier.

import 'package:cloud_firestore/cloud_firestore.dart'; // FirebaseFirestore, QuerySnapshot, FirebaseException
import 'package:flutter/material.dart'; // ChangeNotifier, debugPrint
import 'package:lojavirtual/models/product.dart'; // Product
import 'dart:async'; // StreamSubscription

class ProductManager extends ChangeNotifier { // Notifica UI quando produtos ou busca mudam
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instância do Firestore
  static const String productsCollection = 'products'; // Nome da coleção no Firestore

  bool _loading = false; // true enquanto carrega
  String? _error; // Mensagem de erro ou null
  bool get loading => _loading;
  String? get error => _error;

  StreamSubscription<QuerySnapshot>? _productsSub; // Inscrição no stream (para cancelar no dispose)

  ProductManager() {
    _listenToProducts(); // Inicia escuta ao criar o ProductManager
  }

  List<Product> _allProducts = []; // Lista completa (sem filtro)
  List<Product> get allProducts => List<Product>.unmodifiable(_allProducts); // Cópia imutável (não alterável)

  String _search = ''; // Texto digitado na busca
  String get search => _search;
  set search(String value) {
    _search = value;
    notifyListeners(); // Atualiza UI (filteredProducts muda)
  }

  List<Product> get filteredProducts { // Lista filtrada pelo texto de busca
    final s = _search.trim().toLowerCase(); // Remove espaços, minúsculo
    if (s.isEmpty) return allProducts; // Busca vazia = mostra todos
    return List<Product>.unmodifiable(
      _allProducts.where((p) => p.name.toLowerCase().contains(s)), // Filtra: nome contém o texto
    );
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  void _listenToProducts() { // Escuta coleção 'products' em tempo real
    _setLoading(true);
    _setError(null);
    _productsSub?.cancel(); // Cancela inscrição anterior (evita múltiplas escutas)
    _productsSub = firestore.collection(productsCollection).snapshots().listen(
      (snapshot) { // Callback quando dados mudam no Firestore
        _allProducts = snapshot.docs.map((d) => Product.fromDocument(d)).toList(); // Converte docs em Product
        _setLoading(false);
      },
      onError: (e, st) {
        debugPrint('[ProductManager] Erro: $e'); // Log no console
        if (e is FirebaseException && e.code == 'permission-denied') { // Sem permissão nas Rules
          _allProducts = [];
          _setError('Sem permissão para ler "$productsCollection". Ajuste as Rules do Firestore.');
          _productsSub?.cancel();
          _productsSub = null; // Para de escutar
        } else {
          _setError('Erro ao carregar produtos: $e');
        }
        _setLoading(false);
      },
    );
  }

  void retry() => _listenToProducts(); // Botão "Tentar novamente" na tela de erro

  @override
  void dispose() {
    _productsSub?.cancel(); // Cancela stream (evita memory leak)
    super.dispose();
  }
}
