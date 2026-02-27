import 'package:flutter/material.dart';
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart';
import 'package:lojavirtual/models/product_manager.dart';
import 'package:lojavirtual/screens/products/components/product_list_tile.dart';
import 'package:lojavirtual/screens/products/components/search_dialog.dart';
import 'package:provider/provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.watch<ProductManager>();
    final products = pm.filteredProducts;

    return Scaffold(
      backgroundColor: Colors.blueAccent,
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Consumer<ProductManager>(
          builder: (_, productManager, __) {
            if (productManager.search.isEmpty) {
              return const Text('Produtos', style: TextStyle(color: Colors.white));
            }
            return GestureDetector(
              onTap: () async {
                final search = await showDialog<String>(context: context, builder: (_) => const SearchDialog());
                if (search != null) productManager.search = search;
              },
              child: LayoutBuilder(
                builder: (_, constraints) => SizedBox(
                  width: constraints.maxWidth,
                  child: Text(
                    productManager.search,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          Consumer<ProductManager>(
            builder: (context, productManager, _) {
              if (productManager.search.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final search = await showDialog<String>(context: context, builder: (_) => const SearchDialog());
                    if (search != null) productManager.search = search;
                  },
                );
              }
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.read<ProductManager>().search = '',
              );
            },
          ),
        ],
      ),
      body: pm.loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : pm.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${pm.error}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => context.read<ProductManager>().retry(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blueAccent,
                            ),
                            child: const Text('Tentar novamente'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : products.isEmpty
                  ? const Center(child: Text('Nenhum produto encontrado', style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (_, index) => ProductListTile(products[index]),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        onPressed: () => Navigator.of(context).pushNamed('/cart'),
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
