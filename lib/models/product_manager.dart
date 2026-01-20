import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/models/product.dart'; // Firestore para Flutter

class ProductManager extends ChangeNotifier { // Gerencia os produtos

  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instância do Firestore
 
  

  ProductManager() {
    _loadAllProducts(); // Carrega produtos ao criar a instância
  }

  List<Product> _allProducts = [];
  List<Product> get allProducts => List<Product>.unmodifiable(_allProducts);

  Future<void> _loadAllProducts() async {
    try {
      final QuerySnapshot snapProducts = 
          await firestore.collection('products').get(); // Busca todos os produtos

      _allProducts = snapProducts.docs.map((d) => Product.fromDocument(d)).toList();

      for (final p in _allProducts) {
        print('Produto: ${p.name}'); // Exibe dados de cada produto
      }

      print('Total: ${_allProducts.length}'); // Mostra quantidade carregada
      notifyListeners();
    } catch (e) {
      print('Erro: $e'); // Trata erros
    }
  }
}