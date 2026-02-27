import 'package:flutter/material.dart';
import 'package:lojavirtual/models/item_size.dart';
import 'package:lojavirtual/models/product.dart';
import 'package:provider/provider.dart';

class SizeWidget extends StatelessWidget {
  const SizeWidget({super.key, required this.size});
  final ItemSize size;

  @override
  Widget build(BuildContext context) {
    final product = context.watch<Product>();
    final selected = size == product.selectedSize;
    return GestureDetector(
      onTap: () {
        if (size.hasStock) product.selectedSize = size;
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: !size.hasStock ? Colors.red.withAlpha(50) : selected ? Theme.of(context).primaryColor : Colors.grey,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: !size.hasStock ? Colors.red.withAlpha(50) : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(size.name, style: const TextStyle(color: Colors.white)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'R\$ ${size.price.toDouble().toStringAsFixed(2)}',
                style: TextStyle(color: !size.hasStock ? Colors.red.withAlpha(50) : Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
