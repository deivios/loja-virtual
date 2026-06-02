// ========== BASE_SCREEN.DART - Tela base com PageView ==========
// Tela principal. PageView com 4 abas: Home, Produtos, Meus Pedidos, Lojas.
// Navegação pelo Drawer. Scroll horizontal desativado.

import 'package:flutter/material.dart'; // Scaffold, PageView, AppBar, PageController
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart'; // usado no placeholder de Lojas
import 'package:lojavirtual/models/page_manager.dart'; // Controla índice do PageView
import 'package:lojavirtual/screens/home/home_screen.dart';
import 'package:lojavirtual/screens/orders_screen.dart'; // Meus Pedidos (real)
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
          const OrdersScreen(), // Página 2 - Meus Pedidos (implementado)
          // Página 3 - Lojas (placeholder - pode virar lista de parceiros/filiais)
          Scaffold(
            drawer: const CustomDrawer(),
            appBar: AppBar(title: const Text('Lojas'), centerTitle: true),
            body: const Center(
              child: Text(
                'Lojas / Pontos de retirada\n\n(Em breve: mapa + lista de parceiros)',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
