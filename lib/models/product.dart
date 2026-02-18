import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lojavirtual/models/item_size.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final num basePrice;
  final List<ItemSize> sizes;
  

  // Versão "VS Code / cloud_firestore atual":
  // - document.documentID (antigo) -> document.id
  // - document.data['x'] (antigo) -> (document.data() as Map<String, dynamic>)['x']
  
  Product.fromDocument(DocumentSnapshot document)
      : id = document.id,
        name = (((document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{})['name'] ?? '').toString(),
        description = (((document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{})['description'] ?? '').toString(),
        sizes = _parseSizes(document),
        images = ((((document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{})['images'] as List?)
                    ?.map((e) => e.toString())
                    .toList()) ??
                <String>[],
        // Aceita vários nomes possíveis no Firestore: basePrice/price/preco/valor
        basePrice = _toNum(
              ((document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{})['basePrice'] ??
                  ((document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{})['price'] ??
                  ((document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{})['preco'] ??
                  ((document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{})['valor'],
            ) ??
            0;

  static List<ItemSize> _parseSizes(DocumentSnapshot document) {
    final data = (document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final raw = data['sizes'] as List?;
    if (raw == null || raw.isEmpty) return [];

    return raw.map((e) {
      if (e is Map) {
        return ItemSize.fromMap(Map<String, dynamic>.from(e));
      }
      return ItemSize.fromMap({
        'name': e.toString(),
        'price': 0,
        'stock': 0,
      });
    }).toList();
  }

  static num? _toNum(dynamic v) {
    if (v is num) return v;
    if (v is String) {
      final normalized = v.replaceAll('.', '').replaceAll(',', '.');
      return num.tryParse(normalized);
    }
    return null;
  }

}