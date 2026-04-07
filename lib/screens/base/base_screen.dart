// ========== BASE_SCREEN.DART - Tela base com PageView ==========
// Tela principal. PageView com 4 abas: Home, Produtos, Meus Pedidos, Lojas.
// Navegação pelo Drawer. Scroll horizontal desativado.

import 'package:flutter/material.dart'; // Scaffold, PageView, AppBar, PageController
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart'; // Menu lateral
import 'package:lojavirtual/models/page_manager.dart'; // Controla índice do PageView
import 'package:lojavirtual/screens/home/home_screen.dart';
import 'package:lojavirtual/screens/products/products_screen.dart'; // Lista de produtos
import 'package:provider/provider.dart'; // Provider

class BaseScreen extends StatelessWidget { // Widget sem estado
  final PageController pageController = PageController(); // Controla qual página está visível

  BaseScreen({super.key}); // Construtor

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PageManager>( // Fornece PageManager para os DrawerTiles
      create: (_) => PageManager(pageController), // Cria com o controller - DrawerTiles chamam setPage()
      child: PageView( // Carrossel horizontal de telas
        controller: pageController, // Liga ao controller
        physics: const NeverScrollableScrollPhysics(), // Desativa scroll com dedo - só pelo Drawer
        children: [
          const HomeScreen(), // Página 0 - Home
          ProductsScreen(), // Página 1 - Lista de produtos
          Scaffold( // Página 2 - Meus Pedidos
            backgroundColor: Colors.blueAccent,
            drawer: CustomDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Meus Pedidos', style: TextStyle(color: Colors.white)),
            ),
          ),
          Scaffold( // Página 3 - Lojas
            backgroundColor: Colors.blueAccent,
            drawer: CustomDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Lojas', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
