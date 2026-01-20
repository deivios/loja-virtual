import 'package:flutter/material.dart';                          // Pacote principal do Flutter (Scaffold, AppBar, PageView, etc.)
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart';  
// Importa o Drawer personalizado que criamos anteriormente (menu lateral)

import 'package:lojavirtual/models/page_manager.dart';           // Importa o gerenciador de páginas (PageManager)
import 'package:lojavirtual/screens/login_screen.dart';          // Importa a tela de login (provavelmente usada em algum lugar, mas não aqui)
import 'package:lojavirtual/screens/product/products_screen.dart';
import 'package:provider/provider.dart';                         // Provider para gerenciar estado (neste caso, o PageManager)

class BaseScreen extends StatelessWidget {                     // Tela base do app – usa PageView para navegar entre as páginas sem scroll manual
  final PageController pageController = PageController();     // Controlador do PageView – permite mudar de página programaticamente

  @override
  Widget build(BuildContext context) {
    return Provider<PageManager>(                              // Fornece o PageManager para toda a árvore abaixo via Provider
      create: (_) => PageManager(pageController),             // Cria uma instância nova do PageManager passando o controlador
      // dispose: (_, manager) => manager.dispose(),          // Opcional: limpar recursos quando o widget for destruído (bom adicionar)

      child: PageView(                                         // PageView cria um "carrossel" de telas (navegação horizontal ou por código)
        controller: pageController,                            // Liga o controlador criado acima
        physics: const NeverScrollableScrollPhysics(),         // Desativa o scroll com dedo → só muda de página via código (DrawerTile, botões, etc.)
        children: <Widget>[                                    // Lista de telas (cada uma é um Scaffold diferente)

          // Página 0 - Início / Home
          Scaffold(
            backgroundColor: Colors.blueAccent,                // Cor de fundo da tela inteira
            drawer: CustomDrawer(),                            // Menu lateral (o mesmo em todas as páginas)
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,              // AppBar azul igual ao fundo (efeito "sem barra" visual)
              title: const Text(
                'Home',
                style: TextStyle(color: Colors.white),         // Título em branco (como pedido anteriormente)
              ),
              // centerTitle: true,                            // Opcional: centraliza o título
            ),
            // body: ... aqui vai o conteúdo real da página Home (provavelmente um Center, ListView, GridView, etc.)
          ),
          ProductsScreen(),
          // Página 1
          Scaffold(
            backgroundColor: Colors.blueAccent,
            drawer: CustomDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Home2', style: TextStyle(color: Colors.white)),
            ),
            // body: ...
          ),

          // Página 2
          Scaffold(
            backgroundColor: Colors.blueAccent,
            drawer: CustomDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Home3', style: TextStyle(color: Colors.white)),
            ),
            // body: ...
          ),

          // Página 3
          Scaffold(
            backgroundColor: Colors.blueAccent,
            drawer: CustomDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Home4', style: TextStyle(color: Colors.white)),
            ),
            // body: ...
          ),

          // Página 4
          Scaffold(
            backgroundColor: Colors.blueAccent,
            drawer: CustomDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Home5', style: TextStyle(color: Colors.white)),
            ),
            // body: ...
          ),

        ],
      ),
    );
  }
}