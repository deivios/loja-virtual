import 'package:flutter/material.dart';
import 'package:lojavirtual/models/page_manager.dart';
import 'package:lojavirtual/models/product_manager.dart';
import 'package:lojavirtual/models/section_item.dart';
import 'package:provider/provider.dart';

class ItemTile extends StatelessWidget {
  const ItemTile(this.item, {super.key});

  final SectionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final reference = item.product.trim().isNotEmpty
            ? item.product.trim()
            : item.link.trim();
        if (reference.isEmpty) {
          context.read<ProductManager>().search = '';
          context.read<PageManager>().setPage(1);
          return;
        }

        final productManager = context.read<ProductManager>();
        final product = await productManager.findProductByReference(reference);
        if (!context.mounted) return;

        if (product == null) {
          productManager.search = reference;
          context.read<PageManager>().setPage(1);
          return;
        }

        Navigator.of(context).pushNamed('/product', arguments: product);
      },
      child: AspectRatio(aspectRatio: 1, child: _buildImage()),
    );
  }

  Widget _buildImage() {
    final uri = Uri.tryParse(item.image.trim());
    final hasValidRemoteImage =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;

    if (!hasValidRemoteImage) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      );
    }

    return Image.network(
      item.image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
      ),
    );
  }
}
