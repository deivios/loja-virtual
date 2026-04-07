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
    return raw
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) {
          if (e.isEmpty ||
              e == '[]' ||
              e == '{}' ||
              e.toLowerCase() == 'null' ||
              e.toLowerCase() == 'undefined') {
            return false;
          }
          final uri = Uri.tryParse(e);
          return uri != null &&
              (uri.scheme == 'http' || uri.scheme == 'https') &&
              uri.host.isNotEmpty;
        })
        .toList(); // Apenas URLs remotas válidas
  }

  static num? _toNum(DocumentSnapshot doc, String key1, String key2, String key3, String key4) { // Extrai número
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final v = data[key1] ?? data[key2] ?? data[key3] ?? data[key4]; // Tenta cada chave
    return _parseNum(v);
  }

  static List<ItemSize> _parseSizes(DocumentSnapshot document) { // Converte sizes/tamanhos em List<ItemSize>
    final data = document.data() as Map<String, dynamic>? ?? const {};
    final raw = data['sizes'] ?? data['tamanhos'] ?? data['variacoes'] ?? data['variacoesTamanho'];
    if (raw == null) return []; // Sem tamanhos

    if (raw is List) {
      if (raw.isEmpty) return [];
      return raw
          .map((e) {
            if (e is Map) {
              return ItemSize.fromMap(_normalizeSizeMap(Map<String, dynamic>.from(e)));
            }
            return ItemSize.fromMap({'name': e.toString(), 'price': 0, 'stock': 0});
          })
          .toList();
    }

    if (raw is Map) {
      final mapRaw = Map<String, dynamic>.from(raw);
      if (mapRaw.isEmpty) return [];
      return mapRaw.entries
          .map((entry) {
            if (entry.value is Map) {
              final valueMap = Map<String, dynamic>.from(entry.value as Map);
              valueMap.putIfAbsent('name', () => entry.key);
              return ItemSize.fromMap(_normalizeSizeMap(valueMap));
            }
            return ItemSize.fromMap({
              'name': entry.key,
              'price': entry.value,
              'stock': 0,
            });
          })
          .toList();
    }

    return [];
  }

  static Map<String, dynamic> _normalizeSizeMap(Map<String, dynamic> m) { // Normaliza chaves (name/nome, etc.)
    return {
      'name': (m['name'] ?? m['nome'] ?? m['title'] ?? m['titulo'] ?? m['tamanho'] ?? '-').toString(),
      'price': _parseNum(m['price'] ?? m['preco'] ?? m['preço'] ?? m['valor']) ?? 0,
      'stock': _parseInt(m['stock'] ?? m['estoque'] ?? m['quantidade'] ?? m['qty']) ?? 0,
    };
  }

  static int? _parseInt(dynamic v) { // Converte para int
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final digitsOnly = v.replaceAll(RegExp(r'[^0-9\-]'), '');
      if (digitsOnly.isEmpty) return null;
      return int.tryParse(digitsOnly);
    }
    return null;
  }

  static num? _parseNum(dynamic v) { // Converte para num (aceita vírgula decimal)
    if (v is num) return v;
    if (v is String) {
      var normalized = v.trim();
      normalized = normalized.replaceAll(RegExp(r'[^0-9,.\-]'), '');
      if (normalized.isEmpty) return null;

      final lastComma = normalized.lastIndexOf(',');
      final lastDot = normalized.lastIndexOf('.');
      if (lastComma > -1 && lastDot > -1) {
        final decimalSeparator = lastComma > lastDot ? ',' : '.';
        if (decimalSeparator == ',') {
          normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
        } else {
          normalized = normalized.replaceAll(',', '');
        }
      } else if (lastComma > -1) {
        normalized = normalized.replaceAll(',', '.');
      }

      return num.tryParse(normalized);
    }
    return null;
  }

  num get effectivePrice { // Preço a exibir (base ou menor dos tamanhos)
    if (basePrice > 0) return basePrice; // Usa base se definido
    if (sizes.isEmpty) return 0; // Sem tamanhos = 0
    return sizes.map((s) => s.price).reduce((a, b) => a < b ? a : b); // Menor preço entre os tamanhos
  }

  ItemSize? findSize(String sizeName) { // Busca ItemSize pelo nome (P, M, GG)
    final normalizedQuery = _normalizeSizeToken(sizeName);
    try {
      return sizes.firstWhere(
        (s) => _normalizeSizeToken(s.name) == normalizedQuery,
      );
    } on StateError {
      return null; // firstWhere lança StateError se não encontrar
    }
  }

  String _normalizeSizeToken(String value) {
    return value.trim().toUpperCase();
  }

  ItemSize? _selectedSize; // Tamanho selecionado na tela de detalhes
  ItemSize? get selectedSize => _selectedSize;
  set selectedSize(ItemSize? value) {
    _selectedSize = value;
    notifyListeners(); // Atualiza preço exibido e habilita/desabilita botão Adicionar
  }
}
