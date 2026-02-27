import 'package:flutter/material.dart';
import 'package:lojavirtual/models/product.dart';

class ProductListTile extends StatelessWidget {
  const ProductListTile(this.product, {super.key});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : null;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/product', arguments: product),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Container(
          height: 100,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: imageUrl == null
                      ? Container(color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey))
                      : Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text('A partir de', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 2),
                    Text(
                      _formatBRL(product.effectivePrice),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 4, 80, 142)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBRL(num value) => 'R\$ ${value.toDouble().toStringAsFixed(2).replaceAll('.', ',')}';
}
