import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart';
import 'package:lojavirtual/models/order.dart';
import 'package:lojavirtual/models/user_manager.dart';
import 'package:provider/provider.dart';

/// Tela "Meus Pedidos" - lista os pedidos do usuário logado.
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManager>();
    final user = userManager.user;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('Meus Pedidos'),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Faça login para ver seus pedidos.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('clientId', isEqualTo: user.id)
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar pedidos:\n${snapshot.error}'),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Você ainda não tem pedidos.\n\nFinalize uma compra no carrinho!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final doc = docs[index];
                    // Reconstrói os OrderProduct a partir do array 'items' salvo
                    final itemsData = (doc.data() as Map<String, dynamic>?)?['items'] as List? ?? [];
                    final orderItems = itemsData
                        .map((m) => OrderProduct.fromMap(m as Map<String, dynamic>))
                        .toList();
                    final order = Order.fromDocument(doc, orderItems);
                    return _OrderTile(order);
                  },
                );
              },
            ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile(this.order);

  final Order order;

  @override
  Widget build(BuildContext context) {
    final dateStr = '${order.date.day.toString().padLeft(2, '0')}/'
        '${order.date.month.toString().padLeft(2, '0')}/'
        '${order.date.year} '
        '${order.date.hour.toString().padLeft(2, '0')}:${order.date.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Text('Pedido #${order.id.substring(0, 6)} • ${order.status}'),
        subtitle: Text('Total: R\$ ${order.total.toStringAsFixed(2).replaceAll('.', ',')} • $dateStr'),
        children: order.items.map((item) {
          return ListTile(
            dense: true,
            title: Text('${item.name} • ${item.size}'),
            trailing: Text('${item.quantity}x R\$ ${item.unitPrice.toStringAsFixed(2).replaceAll('.', ',')}'),
            subtitle: Text('Subtotal: R\$ ${item.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}'),
          );
        }).toList(),
      ),
    );
  }
}
