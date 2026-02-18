class ItemSize {
  final String name;
  final num price;
  final int stock;

  ItemSize.fromMap(Map<String, dynamic> map)
      : name = map['name'] as String,
        price = map['price'] as num,
        stock = map['stock'] as int;

        bool get hasStock => stock > 0;

        @override
  String toString(){
    return 'ItemSize{name: $name, price: $price, stock: $stock}';
  }
}
