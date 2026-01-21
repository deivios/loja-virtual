import 'package:flutter/material.dart';                          // Pacote principal do Flutter para widgets (Scaffold, AppBar, ListView, etc.)
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart'; // Importa o Drawer personalizado (menu lateral)
import 'package:lojavirtual/models/product_manager.dart';       // Importa o gerenciador de produtos (ProductManager com ChangeNotifier)
import 'package:lojavirtual/screens/product/components/product_list_tile.dart'; // Importa o widget que exibe cada produto (tile)
import 'package:lojavirtual/screens/product/components/search_dialog.dart';
import 'package:provider/provider.dart';                        // Pacote Provider para acessar o ProductManager via context

class ProductsScreen extends StatelessWidget {                 // Tela de listagem de produtos – widget sem estado (Stateless)
  const ProductsScreen({super.key});                           // Construtor constante (boa prática para performance)

  @override
  Widget build(BuildContext context) {                         // Método que constrói a interface da tela
    final pm = context.watch<ProductManager>();                // Escuta mudanças no ProductManager (rebuild quando notifyListeners)
    final products = pm.allProducts;                           // Pega a lista imutável de produtos do manager

    return Scaffold(                                           // Estrutura principal da tela
      backgroundColor: Colors.blueAccent,                      // Fundo azul da tela inteira
      drawer: CustomDrawer(),                                  // Menu lateral personalizado (o mesmo usado em outras telas)
      appBar: AppBar(                                          // Barra superior da tela
        backgroundColor: Colors.blueAccent,                    // Cor de fundo da AppBar (igual ao fundo da tela)
        iconTheme: const IconThemeData(color: Colors.white),   // Ícone do drawer (hamburguer) em branco
        title: const Text(                                     // Título da AppBar
          'Produtos',
          style: TextStyle(color: Colors.white),               // Texto branco para contraste
        ),
        centerTitle: true,                                     // Centraliza o título na AppBar
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(context: context, builder: (_) => SearchDialog());
            },
          ),
        ],
        
      ),
      body: pm.loading                                       // Condicional: verifica se está carregando
          ? const Center(                                      // Mostra spinner centralizado enquanto carrega
              child: CircularProgressIndicator(color: Colors.white), // Spinner branco para combinar com o tema
            )
          : (pm.error != null)                                 // Se tem erro (ex: permission-denied)
              ? Center(                                            // Exibe mensagem de erro centralizada
                  child: Padding(
                    padding: const EdgeInsets.all(16),             // Espaçamento ao redor do conteúdo
                    child: Column(
                      mainAxisSize: MainAxisSize.min,              // Coluna ocupa só o espaço necessário
                      children: [
                        Text(                                      // Texto explicando o erro
                          'Sem permissão para ler os produtos no Firestore.\n\n'
                          'Erro:\n${pm.error}',
                          textAlign: TextAlign.center,             // Centraliza o texto
                          style: const TextStyle(color: Colors.white), // Texto branco
                        ),
                        const SizedBox(height: 16),                // Espaço vertical
                        SizedBox(                                  // Botão com altura fixa
                          height: 44,
                          child: ElevatedButton(                   // Botão "Tentar novamente"
                            onPressed: () => context.read<ProductManager>().retry(), // Chama método retry() do manager
                            style: ElevatedButton.styleFrom(       // Estilo do botão
                              backgroundColor: Colors.white,       // Fundo branco
                              foregroundColor: Colors.blueAccent,  // Texto e ícone azul
                            ),
                            child: const Text('Tentar novamente'), // Texto do botão
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : products.isEmpty                                   // Se não tem erro e lista vazia
                  ? const Center(                                    // Mensagem centralizada
                      child: Text(
                        'Nenhum produto encontrado',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(                                // Lista rolável de produtos
                      itemCount: products.length,                    // Número total de itens
                      itemBuilder: (_, index) {                      // Construtor de cada item
                        final p = products[index];                   // Produto atual no índice
                        return ProductListTile(p);                   // Retorna o tile personalizado
                      },
                    ),
    );
  }
}