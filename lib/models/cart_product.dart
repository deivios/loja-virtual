import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lojavirtual/models/item_size.dart';
import 'package:lojavirtual/models/product.dart';

class CartProduct {
  final String productId;
  int quantity;
  final String size;
  final Product product;

  CartProduct.fromProduct(Product product)
      : product = product,
        productId = product.id,
        quantity = 1,
        size = product.selectedSize!.name;

  CartProduct.fromDocument(DocumentSnapshot doc, Product product)
      : product = product,
        productId = product.id,
        quantity = (doc.data() as Map<String, dynamic>? ?? {})['quantity'] as int? ?? 1,
        size = (doc.data() as Map<String, dynamic>? ?? {})['size'] as String? ?? '';

  ItemSize? get itemSize {
    if (product.sizes.isEmpty) return null;
    return product.findSize(size);
  }

  num get unitPrice => itemSize?.price ?? product.effectivePrice;

  bool stackable(Product product) {
    return productId == product.id && size == (product.selectedSize?.name ?? '');
  }

  Map<String, dynamic> toCartItemMap() => {
        'pid': productId,
        'quantity': quantity,
        'size': size,
      };
}
