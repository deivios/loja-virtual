// ========== CART_PRODUCT.DART - Item do carrinho ==========
// Produto + quantidade + tamanho. fromProduct (tela) ou fromDocument (Firestore).

import 'package:cloud_firestore/cloud_firestore.dart'; // DocumentSnapshot
import 'package:lojavirtual/models/item_size.dart'; // ItemSize
import 'package:lojavirtual/models/product.dart'; // Product

class CartProduct {
  final String productId; // ID do produto no Firestore
  int quantity; // Quantidade (pode incrementar ao adicionar de novo)
  final String size; // Tamanho escolhido (P, M, GG)
  final Product
  product; // Referência ao Product completo (nome, imagens, preços)
  String?
  firestoreDocId; // ID do documento no Firestore (users/{uid}/cart/{id})

  CartProduct.fromProduct(
    Product product,
  ) // Construtor ao adicionar na tela de detalhes
  : product = product,
      productId = product.id,
      quantity = 1, // Quantidade inicial sempre 1
      size =
          product.selectedSize!.name, // Tamanho que estava selecionado na tela
      firestoreDocId = null;

  CartProduct.fromDocument(
    DocumentSnapshot doc,
    Product product,
  ) // Construtor ao carregar do Firestore
  : product = product,
      productId = product.id,
      quantity =
          (doc.data() as Map<String, dynamic>? ?? {})['quantity'] as int? ??
          1, // Pega do doc ou 1
      size =
          (doc.data() as Map<String, dynamic>? ?? {})['size'] as String? ??
          '', // Pega do doc ou vazio
      firestoreDocId = doc.id;

  ItemSize? get itemSize {
    // Retorna ItemSize do tamanho (para obter preço)
    if (product.sizes.isEmpty) return null; // Sem tamanhos
    return product.findSize(size); // Busca pelo nome (P, M, GG)
  }

  bool get hasStock {
    final s = itemSize;
    if (s == null) return false;
    return s.stock >= quantity;
  }

  num get unitPrice =>
      itemSize?.price ??
      product.effectivePrice; // Preço unitário: do tamanho ou base

  num get totalPrice =>
      unitPrice * quantity; // Preço total (unitário × quantidade)

  void Function()? _onIncrement; // Callback injetado pelo CartManager
  void Function()? _onDecrement; // Callback injetado pelo CartManager
  void Function()? _onRemove; // Callback para remover item por completo

  void setCallbacks({
    void Function()? onIncrement,
    void Function()? onDecrement,
    void Function()? onRemove,
  }) {
    // CartManager chama ao adicionar/carregar itens
    _onIncrement = onIncrement;
    _onDecrement = onDecrement;
    _onRemove = onRemove;
  }

  void increment() {
    // Aumenta quantidade (chama callback que atualiza Firestore e UI)
    _onIncrement?.call();
  }

  void decrement() {
    // Diminui quantidade (chama callback; se zerar, remove do carrinho)
    _onDecrement?.call();
  }

  void remove() {
    // Remove item por completo (chama callback)
    _onRemove?.call();
  }

  bool stackable(Product product) {
    // Pode empilhar? (mesmo produto + mesmo tamanho)
    return productId == product.id &&
        size == (product.selectedSize?.name ?? '');
  }

  Map<String, dynamic> toCartItemMap() => {
    // Converte para salvar no Firestore
    'pid': productId, // pid = product id (nome curto)
    'quantity': quantity,
    'size': size,
  };
}
