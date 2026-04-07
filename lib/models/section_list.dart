import 'package:lojavirtual/models/section_item.dart';

class SectionList {
  SectionList({required this.items});

  final List<SectionItem> items;

  factory SectionList.fromList(List<dynamic> rawItems) {
    final parsedItems = rawItems
        .whereType<Map>()
        .map((item) => SectionItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();

    return SectionList(items: parsedItems);
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  int get length => items.length;
}
