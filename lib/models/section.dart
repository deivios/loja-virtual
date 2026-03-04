import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lojavirtual/models/section_item.dart';

class Section {
  Section.fromDocument(DocumentSnapshot document) {
    // construtor a partir de um documento do Firestore
    final data =
        document.data() as Map<String, dynamic>? ??
        {}; // obtém os dados do documento (mapa vazio se null)
    name = (data['name'] ?? '') as String; // extrai o campo name
    type = (data['type'] ?? '') as String; // extrai o campo type
    items = ((data['items'] ?? []) as List)
        .map(
          // extrai a lista 'items', percorre e converte cada elemento
          (i) => SectionItem.fromMap(i as Map<String, dynamic>),
        )
        .toList(); // em SectionItem usando fromMap
  }

  late String name; // nome da seção
  late String type; // tipo da seção
  late List<SectionItem> items; // lista de itens (imagens, etc.) da seção

  @override
  String toString() {
    return 'Section{name:$name, type: $type, items: $items}';
  }
}
