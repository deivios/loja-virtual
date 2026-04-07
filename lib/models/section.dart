import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lojavirtual/models/section_item.dart';

class Section {
  Section.fromDocument(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>? ?? {};
    name = (data['name'] ?? '').toString();
    type = (data['type'] ?? 'list').toString();

    final rawItems = data['items'];
    if (rawItems is List) {
      items = rawItems
          .whereType<Map>()
          .map((i) => SectionItem.fromMap(Map<String, dynamic>.from(i)))
          .toList();
    } else {
      items = _fallbackItemsFromDocument(data);
    }
  }

  late String name;
  late String type;
  late List<SectionItem> items;

  List<SectionItem> _fallbackItemsFromDocument(Map<String, dynamic> data) {
    final fallbackImageValues = <dynamic>[
      data['images'],
      data['image'],
      data['url'],
    ];

    final fallbackProduct = (data['product'] ??
            data['produto'] ??
            data['productId'] ??
            data['product_id'] ??
            data['pid'] ??
            '')
        .toString();

    final fallbackLink =
        (data['link'] ?? data['target'] ?? data['externalUrl'] ?? '')
            .toString();

    final parsed = <SectionItem>[];
    for (final value in fallbackImageValues) {
      if (value is List) {
        for (final image in value) {
          parsed.add(
            SectionItem.fromMap({
              'image': image,
              'product': fallbackProduct,
              'link': fallbackLink,
            }),
          );
        }
      } else if (value != null) {
        parsed.add(
          SectionItem.fromMap({
            'image': value,
            'product': fallbackProduct,
            'link': fallbackLink,
          }),
        );
      }
    }

    return parsed.where((item) => item.image.trim().isNotEmpty).toList();
  }

  @override
  String toString() {
    return 'Section{name:$name, type: $type, items: $items}';
  }
}
