import 'package:flutter/material.dart';                          // Importa widgets básicos do Flutter (Scaffold, AppBar, ListView, Text, etc.)
// Importa classes relacionadas a renderização (usado indiretamente em alguns casos)
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart'; // Importa o Drawer (menu lateral) personalizado do app
import 'package:lojavirtual/models/product_manager.dart';       // Importa o gerenciador de produtos (ProductManager)
import 'package:lojavirtual/screens/products/components/product_list_tile.dart'; // Importa o widget que exibe cada produto individualmente
import 'package:lojavirtual/screens/products/components/search_dialog.dart'; // Importa o diálogo de busca
import 'package:provider/provider.dart';                        // Importa o Provider para gerenciamento de estado via contexto

class ProductsScreen extends StatelessWidget {                 // Define a tela de produtos como um widget sem estado (StatelessWidget)
  const ProductsScreen({super.key});                           // Construtor constante (melhor performance e recomendado)

  @override
  Widget build(BuildContext context) {                         // Método principal que constrói a interface da tela
    final pm = context.watch<ProductManager>();                // Obtém e escuta o ProductManager (rebuild automático quando notifyListeners é chamado)
    final products = pm.filteredProducts;                      // Pega a lista de produtos já filtrada pelo texto de busca atual

    return Scaffold(                                           // Estrutura principal da tela (AppBar + body + drawer)
      backgroundColor: Colors.blueAccent,                      // Define a cor de fundo da tela inteira
      drawer: CustomDrawer(),                                  // Adiciona o menu lateral personalizado (geralmente com navegação do app)

      appBar: AppBar(                                          // Barra superior da tela
        backgroundColor: Colors.blueAccent,                    // Mesma cor de fundo da tela (efeito visual contínuo)
        iconTheme: const IconThemeData(color: Colors.white),   // Define a cor do ícone do drawer (hambúrguer) como branco
        title: Consumer<ProductManager>(                       // Consumer escuta apenas mudanças no ProductManager para o título
          builder: (_, productManager, __) {                   // Builder chamado sempre que ProductManager notificar mudanças
            if (productManager.search.isEmpty) {               // Se não há texto de busca ativo
              return const Text(                               // Mostra o título padrão "Produtos"
                'Produtos',
                style: TextStyle(color: Colors.white),
              );
            }

            return GestureDetector(                            // Torna o texto clicável para abrir o diálogo de busca
              onTap: () async {                                // Quando o usuário clicar no texto da busca atual
                final search = await showDialog<String>(       // Abre o diálogo de busca e espera o retorno
                  context: context,
                  builder: (_) => const SearchDialog(),        // Instancia o diálogo de busca
                );
                if (search != null) {                          // Se o usuário confirmou (não cancelou)
                  productManager.search = search;              // Atualiza o texto de busca no gerenciador
                }
              },
              child: LayoutBuilder(                            // LayoutBuilder ajuda a obter as restrições de tamanho disponíveis
                builder: (_, constraints) {
                  return SizedBox(                             // Container com largura máxima disponível
                    width: constraints.maxWidth,
                    child: Text(
                      productManager.search,                   // Mostra o texto de busca atual
                      maxLines: 1,                             // Limita a uma linha apenas
                      overflow: TextOverflow.ellipsis,         // Coloca reticências (...) se o texto for muito longo
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,             // Centraliza o texto
                    ),
                  );
                },
              ),
            );
          },
        ),
        centerTitle: true,                                     // Centraliza o título (ou o texto de busca) na AppBar
        actions: <Widget>[                                     // Ações à direita da AppBar
          Consumer<ProductManager>(                            // Consumer para reagir a mudanças no estado de busca
            builder: (context, productManager, _) {
              if (productManager.search.isEmpty) {             // Se não há busca ativa → mostra ícone de lupa
                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {                        // Ao clicar na lupa
                    final search = await showDialog<String>(   // Abre o diálogo de busca
                      context: context,
                      builder: (_) => const SearchDialog(),
                    );
                    if (search != null) {                      // Se o usuário digitou e confirmou
                      productManager.search = search;          // Atualiza o filtro de busca
                    }
                  },
                );
              }

              return IconButton(                               // Se há busca ativa → mostra ícone de limpar (X)
                icon: const Icon(Icons.close),
                onPressed: () async {
                  context.read<ProductManager>().search = '';  // Limpa o texto de busca (mostra todos os produtos novamente)
                },
              );
            },
          ),
        ],
      ),

      body: pm.loading                                         // Verifica se os produtos ainda estão carregando
          ? const Center(                                      // Caso esteja carregando → mostra indicador de progresso
              child: CircularProgressIndicator(color: Colors.white),
            )
          : (pm.error != null)                                 // Se houve erro (ex: permission-denied)
              ? Center(                                            // Mostra mensagem de erro centralizada
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Sem permissão para ler os produtos no Firestore.\n\n'
                          'Erro:\n${pm.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => context.read<ProductManager>().retry(), // Botão para tentar carregar novamente
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
              : products.isEmpty                                   // Se carregou, mas não tem produtos (ou nenhum corresponde à busca)
                  ? const Center(
                      child: Text(
                        'Nenhum produto encontrado',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(                                // Lista rolável otimizada (só constrói itens visíveis)
                      itemCount: products.length,                    // Quantidade total de produtos filtrados
                      itemBuilder: (_, index) {                      // Função que constrói cada item da lista
                        final p = products[index];                   // Produto correspondente ao índice atual
                        return ProductListTile(p);                   // Exibe o widget personalizado de cada produto
                      },
                    ),
    );
  }
}