import 'package:flutter/material.dart';
import 'package:lojavirtual/models/cart_product.dart';

class CartTile extends StatelessWidget {
  const CartTile(this.cartProduct, {super.key});

  final CartProduct cartProduct;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: cartProduct.product.images.isNotEmpty
                  ? Image.network(
                      cartProduct.product.images.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cartProduct.product.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Tamanho: ${cartProduct.size}',
                        style: const TextStyle(fontWeight: FontWeight.w300),
                      ),
                    ),
                    Text(
                      _formatPrice(cartProduct),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(CartProduct cp) {
    if (cp.product.sizes.isEmpty) {
      final total = cp.product.effectivePrice * cp.quantity;
      return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    final itemSize = cp.itemSize;
    if (itemSize == null) {
      final total = cp.product.effectivePrice * cp.quantity;
      return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    final total = itemSize.price * cp.quantity;
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
