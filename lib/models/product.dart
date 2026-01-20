import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final List<String> images;
  final num basePrice;

  // Versão "VS Code / cloud_firestore atual":
  // - document.documentID (antigo) -> document.id
  // - document.data['x'] (antigo) -> (document.data() as Map<String, dynamic>)['x']
  Product.fromDocument(DocumentSnapshot document)
      : id = document.id,
        name = (((document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{})['name'] ?? '').toString(),
        description = (((document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{})['description'] ?? '').toString(),
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

  static num? _toNum(dynamic v) {
    if (v is num) return v;
    if (v is String) {
      final normalized = v.replaceAll('.', '').replaceAll(',', '.');
      return num.tryParse(normalized);
    }
    return null;
  }

}