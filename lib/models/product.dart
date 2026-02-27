import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lojavirtual/models/item_size.dart';

class Product extends ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final num basePrice;
  final List<ItemSize> sizes;

  Product.fromDocument(DocumentSnapshot document)
      : id = document.id,
        name = _toString(document, 'name'),
        description = _toString(document, 'description'),
        images = _toImages(document),
        basePrice = _toNum(document, 'basePrice', 'price', 'preco', 'valor') ?? 0,
        sizes = _parseSizes(document) {
    _selectedSize = null;
  }

  static String _toString(DocumentSnapshot doc, String key) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return (data[key] ?? '').toString();
  }

  static List<String> _toImages(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final raw = data['images'] as List?;
    if (raw == null) return [];
    return raw.map((e) => e.toString()).toList();
  }

  static num? _toNum(DocumentSnapshot doc, String key1, String key2, String key3, String key4) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final v = data[key1] ?? data[key2] ?? data[key3] ?? data[key4];
    if (v is num) return v;
    if (v is String) return num.tryParse(v.replaceAll('.', '').replaceAll(',', '.'));
    return null;
  }

  static List<ItemSize> _parseSizes(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>? ?? const {};
    final raw = (data['sizes'] ?? data['tamanhos']) as List?;
    if (raw == null || raw.isEmpty) return [];

    return raw.map((e) {
      if (e is Map) {
        return ItemSize.fromMap(_normalizeSizeMap(Map<String, dynamic>.from(e)));
      }
      return ItemSize.fromMap({'name': e.toString(), 'price': 0, 'stock': 0});
    }).toList();
  }

  static Map<String, dynamic> _normalizeSizeMap(Map<String, dynamic> m) {
    return {
      'name': (m['name'] ?? m['nome'] ?? '-').toString(),
      'price': _parseNum(m['price'] ?? m['preco']) ?? 0,
      'stock': _parseInt(m['stock'] ?? m['estoque']) ?? 0,
    };
  }

  static int? _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static num? _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v.replaceAll(',', '.'));
    return null;
  }

  num get effectivePrice {
    if (basePrice > 0) return basePrice;
    if (sizes.isEmpty) return 0;
    return sizes.map((s) => s.price).reduce((a, b) => a < b ? a : b);
  }

  ItemSize? findSize(String sizeName) {
    try {
      return sizes.firstWhere((s) => s.name == sizeName);
    } on StateError {
      return null;
    }
  }

  ItemSize? _selectedSize;
  ItemSize? get selectedSize => _selectedSize;
  set selectedSize(ItemSize? value) {
    _selectedSize = value;
    notifyListeners();
  }
}
