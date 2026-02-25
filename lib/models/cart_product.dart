import 'package:cloud_firestore/cloud_firestore.dart'; // Pacote Firestore para DocumentSnapshot
import 'package:lojavirtual/models/item_size.dart'; // Importa o modelo ItemSize (tamanho com nome, preço, estoque)
import 'package:lojavirtual/models/product.dart'; // Importa o modelo Product (produto com nome, preço, tamanhos)

class CartProduct {
  // Classe que representa um produto no carrinho de compras
  CartProduct.fromProduct(
    this.product,
  ) // Construtor: cria CartProduct a partir de um Product
  : productId =
          product.id, // Guarda o ID do produto (para identificar no Firestore)
      quantity = 1, // Quantidade inicial ao adicionar no carrinho
      size = product
          .selectedSize!
          .name; // Nome do tamanho selecionado (P, M, GG) – exige que tenha tamanho

  CartProduct._({
    required this.productId,
    required this.quantity,
    required this.size,
    required this.product,
  }); // Construtor privado para fromDocument

  factory CartProduct.fromDocument(DocumentSnapshot doc, Product product) {
    // Cria CartProduct a partir de documento do Firestore
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CartProduct._(
      productId: product.id, // ID do produto
      quantity: (data['quantity'] ?? 1) as int, // Quantidade do documento
      size: (data['size'] ?? '') as String, // Tamanho do documento
      product: product, // Product completo
    );
  }

  final String productId; // ID do produto no Firestore
  int quantity; // Quantidade deste item no carrinho
  final String size; // Tamanho escolhido (ex: "P", "M", "GG")
  final Product
  product; // Referência ao Product completo (nome, imagens, preços)

  ItemSize? get itemSize {
    // Getter que retorna o ItemSize correspondente ao tamanho do carrinho
    if (product.sizes.isEmpty) return null; // Se não tem tamanhos, retorna null
    return product.findSize(
      size,
    ); // Usa o método findSize do Product para buscar pelo nome
  }

  num get unitPrice {
    // Getter que retorna o preço unitário deste item
    return itemSize?.price ??
        product
            .effectivePrice; // Preço do tamanho ou preço efetivo se itemSize for null
  }
}
