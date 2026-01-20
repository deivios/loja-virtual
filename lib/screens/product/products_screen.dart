import 'package:flutter/material.dart';
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart';
import 'package:lojavirtual/models/product_manager.dart';
import 'package:lojavirtual/screens/product/components/product_list_tile.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductManager>().allProducts;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Produtos',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: products.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) {
                final p = products[index];
                return ProductListTile(p);
              },
            ),
    );
  }
}