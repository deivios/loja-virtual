// ========== PRODUCT.DART - Modelo de produto ==========
// Dados do Firestore. ChangeNotifier para selectedSize (atualiza preço/botão).

import 'package:cloud_firestore/cloud_firestore.dart'; // DocumentSnapshot
import 'package:flutter/foundation.dart'; // ChangeNotifier
import 'package:lojavirtual/models/item_size.dart'; // ItemSize

class Product extends ChangeNotifier { // Notifica quando selectedSize muda
  final String id; // ID do documento no Firestore
  final String name; // Nome do produto
  final String description; // Descrição textual
  final List<String> images; // URLs das imagens (Firebase Storage)
  final num basePrice; // Preço base (fallback quando não há tamanhos)
  final List<ItemSize> sizes; // Lista de tamanhos (P, M, GG) com preço e estoque

  Product.fromDocument(DocumentSnapshot document) // Construtor a partir do Firestore
      : id = document.id,
        name = _toString(document, 'name'),
        description = _toString(document, 'description'),
        images = _toImages(document),
        basePrice = _toNum(document, 'basePrice', 'price', 'preco', 'valor') ?? 0, // Tenta vários nomes de campo
        sizes = _parseSizes(document) {
    _selectedSize = null; // Sem tamanho selecionado ao criar
  }

  static String _toString(DocumentSnapshot doc, String key) { // Extrai String de um campo
    final data = doc.data() as Map<String, dynamic>? ?? {}; // Campos do documento
    return (data[key] ?? '').toString(); // Converte para String (pode vir como num)
  }

  static List<String> _toImages(DocumentSnapshot doc) { // Extrai lista de imagens
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final raw = data['images'] as List?; // Campo images do Firestore
    if (raw == null) return []; // Sem imagens
    return raw.map((e) => e.toString()).toList(); // Garante que cada elemento é String
  }

  static num? _toNum(DocumentSnapshot doc, String key1, String key2, String key3, String key4) { // Extrai número
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final v = data[key1] ?? data[key2] ?? data[key3] ?? data[key4]; // Tenta cada chave
    if (v is num) return v; // Já é número
    if (v is String) return num.tryParse(v.replaceAll('.', '').replaceAll(',', '.')); // "1.234,56" -> 1234.56
    return null;
  }

  static List<ItemSize> _parseSizes(DocumentSnapshot document) { // Converte sizes/tamanhos em List<ItemSize>
    final data = document.data() as Map<String, dynamic>? ?? const {};
    final raw = (data['sizes'] ?? data['tamanhos']) as List?; // Aceita sizes ou tamanhos
    if (raw == null || raw.isEmpty) return []; // Sem tamanhos

    return raw.map((e) {
      if (e is Map) { // Cada tamanho é um Map com name, price, stock
        return ItemSize.fromMap(_normalizeSizeMap(Map<String, dynamic>.from(e)));
      }
      return ItemSize.fromMap({'name': e.toString(), 'price': 0, 'stock': 0}); // Ou só string "P"
    }).toList();
  }

  static Map<String, dynamic> _normalizeSizeMap(Map<String, dynamic> m) { // Normaliza chaves (name/nome, etc.)
    return {
      'name': (m['name'] ?? m['nome'] ?? '-').toString(),
      'price': _parseNum(m['price'] ?? m['preco']) ?? 0,
      'stock': _parseInt(m['stock'] ?? m['estoque']) ?? 0,
    };
  }

  static int? _parseInt(dynamic v) { // Converte para int
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static num? _parseNum(dynamic v) { // Converte para num (aceita vírgula decimal)
    if (v is num) return v;
    if (v is String) return num.tryParse(v.replaceAll(',', '.')); // Vírgula -> ponto
    return null;
  }

  num get effectivePrice { // Preço a exibir (base ou menor dos tamanhos)
    if (basePrice > 0) return basePrice; // Usa base se definido
    if (sizes.isEmpty) return 0; // Sem tamanhos = 0
    return sizes.map((s) => s.price).reduce((a, b) => a < b ? a : b); // Menor preço entre os tamanhos
  }

  ItemSize? findSize(String sizeName) { // Busca ItemSize pelo nome (P, M, GG)
    try {
      return sizes.firstWhere((s) => s.name == sizeName);
    } on StateError {
      return null; // firstWhere lança StateError se não encontrar
    }
  }

  ItemSize? _selectedSize; // Tamanho selecionado na tela de detalhes
  ItemSize? get selectedSize => _selectedSize;
  set selectedSize(ItemSize? value) {
    _selectedSize = value;
    notifyListeners(); // Atualiza preço exibido e habilita/desabilita botão Adicionar
  }
}
