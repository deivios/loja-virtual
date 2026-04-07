// Tela de listagem de produtos com busca e estados de carregamento/erro.

import 'package:flutter/material.dart'; // Widgets Material.
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart'; // Drawer lateral.
import 'package:lojavirtual/models/product_manager.dart'; // Estado de produtos.
import 'package:lojavirtual/screens/products/components/product_list_tile.dart'; // Item da lista.
import 'package:lojavirtual/screens/products/components/search_dialog.dart'; // Dialog de busca.
import 'package:provider/provider.dart'; // Provider (watch/read/consumer).

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.watch<ProductManager>(); // Observa mudanças do manager.
    final products = pm.filteredProducts; // Produtos após filtro de busca.

    return Scaffold(
      backgroundColor: const Color.fromARGB(151, 95, 48, 48), // Fundo da tela.
      drawer: CustomDrawer(), // Menu lateral.
      appBar: AppBar(
        backgroundColor: Colors.blueGrey, // Cor da AppBar.
        iconTheme: const IconThemeData(
          color: Color(0x000000ff),
        ), // Cor dos ícones.
        title: Consumer<ProductManager>(
          builder: (_, productManager, __) {
            if (productManager.search.isEmpty) {
              return const Text(
                'Produtos',
                style: TextStyle(color: Colors.black),
              ); // Título padrão.
            }

            return GestureDetector(
              onTap: () async {
                final search = await showDialog<String>(
                  context: context,
                  builder: (_) => const SearchDialog(),
                );
                if (search != null) {
                  productManager.search = search; // Atualiza busca.
                }
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
                  ), // Mostra texto da busca ativa.
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
                    final search = await showDialog<String>(
                      context: context,
                      builder: (_) => const SearchDialog(),
                    );
                    if (search != null) {
                      productManager.search = search;
                    }
                  }, // Abre busca.
                );
              }
              return IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.read<ProductManager>().search = '',
              ); // Limpa busca.
            },
          ),
        ],
      ),
      body: pm.loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ) // Estado de loading.
          : pm.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${pm.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ), // Mensagem de erro.
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => context.read<ProductManager>().retry(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.blueAccent,
                        ),
                        child: const Text('Tentar novamente'),
                      ), // Botão de retry.
                    ),
                  ],
                ),
              ),
            )
          : products.isEmpty
          ? const Center(
              child: Text(
                'Nenhum produto encontrado',
                style: TextStyle(color: Colors.lightGreen),
              ),
            ) // Lista vazia.
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) => ProductListTile(products[index]),
            ), // Lista de produtos.
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        onPressed: () => Navigator.of(context).pushNamed('/cart'),
        child: const Icon(Icons.shopping_cart),
      ), // Atalho para carrinho.
    );
  }
}
