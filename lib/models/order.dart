import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lojavirtual/models/cart_product.dart';

/// Representa um pedido finalizado pelo cliente.
/// Armazena snapshot dos itens no momento da compra (para histórico).
class Order {
  final String id;
  final String clientId;
  final List<OrderProduct> items;
  final num total;
  final DateTime date;
  final String status; // Pendente | Em preparação | Enviado | Entregue | Cancelado

  Order({
    required this.id,
    required this.clientId,
    required this.items,
    required this.total,
    required this.date,
    this.status = 'Pendente',
  });

  /// Cria Order a partir de documento Firestore + lista de OrderProduct já montada.
  factory Order.fromDocument(DocumentSnapshot doc, List<OrderProduct> items) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Order(
      id: doc.id,
      clientId: (data['clientId'] ?? '') as String,
      items: items,
      total: (data['total'] as num?) ?? 0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: (data['status'] ?? 'Pendente') as String,
    );
  }

  /// Converte para Map para salvar no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }
}

/// Item de pedido (snapshot no momento da compra, sem depender de Product vivo).
class OrderProduct {
  final String productId;
  final String name;
  final String size;
  final int quantity;
  final num unitPrice;

  OrderProduct({
    required this.productId,
    required this.name,
    required this.size,
    required this.quantity,
    required this.unitPrice,
  });

  num get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toMap() => {
        'pid': productId,
        'name': name,
        'size': size,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };

  factory OrderProduct.fromCartProduct(CartProduct cp) {
    // Usa o nome do produto no momento da compra (denormalizado)
    final productName = cp.product.name; // Product tem 'name'? (ver product.dart)
    return OrderProduct(
      productId: cp.productId,
      name: productName.isNotEmpty ? productName : 'Produto',
      size: cp.size,
      quantity: cp.quantity,
      unitPrice: cp.unitPrice,
    );
  }

  factory OrderProduct.fromMap(Map<String, dynamic> map) {
    return OrderProduct(
      productId: (map['pid'] ?? '') as String,
      name: (map['name'] ?? 'Produto') as String,
      size: (map['size'] ?? '') as String,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unitPrice'] as num?) ?? 0,
    );
  }
}
