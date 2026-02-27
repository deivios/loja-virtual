class ItemSize {
  final String name;
  final num price;
  final int stock;

  ItemSize.fromMap(Map<String, dynamic> map)
      : name = (map['name'] ?? map['nome'] ?? '-').toString(),
        price = _parseNum(map['price'] ?? map['preco']),
        stock = _parseInt(map['stock'] ?? map['estoque']);

  static num _parseNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v.replaceAll(',', '.')) ?? 0;
    return 0;
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  bool get hasStock => stock > 0;
}
