// ========== PRODUCTS_SCREEN.DART - Lista de produtos ==========
// Loading, erro ou lista. Título = busca. Lupa/X. FAB carrinho.

import 'package:flutter/material.dart'; // Scaffold, AppBar, ListView, etc.
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart'; // Menu lateral
import 'package:lojavirtual/models/product_manager.dart'; // ProductManager
import 'package:lojavirtual/screens/products/components/product_list_tile.dart'; // ProductListTile
import 'package:lojavirtual/screens/products/components/search_dialog.dart'; // SearchDialog
import 'package:provider/provider.dart'; // context.watch, context.read, Consumer

class ProductsScreen extends StatelessWidget { // Widget sem estado
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pm = context.watch<ProductManager>(); // Escuta mudanças (loading, error, search)
    final products = pm.filteredProducts; // Lista filtrada pela busca

    return Scaffold(
      backgroundColor: Colors.blueAccent, // Cor de fundo azul
      drawer: CustomDrawer(), // Menu lateral
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white), // Ícone hambúrguer branco
        title: Consumer<ProductManager>(
          builder: (_, productManager, __) {
            if (productManager.search.isEmpty) {
              return const Text('Produtos', style: TextStyle(color: Colors.white)); // Título padrão
            }
            return GestureDetector( // Título clicável quando há busca
              onTap: () async {
                final search = await showDialog<String>(context: context, builder: (_) => const SearchDialog());
                if (search != null) productManager.search = search; // Atualiza busca
              },
              child: LayoutBuilder(
                builder: (_, constraints) => SizedBox(
                  width: constraints.maxWidth, // Ocupa largura disponível
                  child: Text(
                    productManager.search, // Mostra texto da busca
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Corta com "..." se longo
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
        centerTitle: true, // Centraliza título
        actions: [
          Consumer<ProductManager>(
            builder: (context, productManager, _) {
              if (productManager.search.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.search), // Ícone lupa
                  onPressed: () async {
                    final search = await showDialog<String>(context: context, builder: (_) => const SearchDialog());
                    if (search != null) productManager.search = search;
                  },
                );
              }
              return IconButton(
                icon: const Icon(Icons.close), // Ícone X
                onPressed: () => context.read<ProductManager>().search = '', // Limpa busca
              );
            },
          ),
        ],
      ),
      body: pm.loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white)) // Loading: spinner branco
          : pm.error != null
              ? Center( // Erro: mensagem + botão retry
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
                            onPressed: () => context.read<ProductManager>().retry(), // Tenta carregar de novo
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
                  ? const Center(child: Text('Nenhum produto encontrado', style: TextStyle(color: Colors.white))) // Lista vazia
                  : ListView.builder( // Lista de produtos
                      itemCount: products.length,
                      itemBuilder: (_, index) => ProductListTile(products[index]),
                    ),
      floatingActionButton: FloatingActionButton( // Botão flutuante do carrinho
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).primaryColor,
        onPressed: () => Navigator.of(context).pushNamed('/cart'), // Vai para tela do carrinho
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}
