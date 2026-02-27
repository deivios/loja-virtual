import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/models/product.dart';
import 'dart:async';

class ProductManager extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const String productsCollection = 'products';

  bool _loading = false;
  String? _error;
  bool get loading => _loading;
  String? get error => _error;

  StreamSubscription<QuerySnapshot>? _productsSub;

  ProductManager() {
    _listenToProducts();
  }

  List<Product> _allProducts = [];
  List<Product> get allProducts => List<Product>.unmodifiable(_allProducts);

  String _search = '';
  String get search => _search;
  set search(String value) {
    _search = value;
    notifyListeners();
  }

  List<Product> get filteredProducts {
    final s = _search.trim().toLowerCase();
    if (s.isEmpty) return allProducts;
    return List<Product>.unmodifiable(
      _allProducts.where((p) => p.name.toLowerCase().contains(s)),
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

  void _listenToProducts() {
    _setLoading(true);
    _setError(null);
    _productsSub?.cancel();
    _productsSub = firestore.collection(productsCollection).snapshots().listen(
      (snapshot) {
        _allProducts = snapshot.docs.map((d) => Product.fromDocument(d)).toList();
        _setLoading(false);
      },
      onError: (e, st) {
        debugPrint('[ProductManager] Erro: $e');
        if (e is FirebaseException && e.code == 'permission-denied') {
          _allProducts = [];
          _setError('Sem permissão para ler "$productsCollection". Ajuste as Rules do Firestore.');
          _productsSub?.cancel();
          _productsSub = null;
        } else {
          _setError('Erro ao carregar produtos: $e');
        }
        _setLoading(false);
      },
    );
  }

  void retry() => _listenToProducts();

  @override
  void dispose() {
    _productsSub?.cancel();
    super.dispose();
  }
}
