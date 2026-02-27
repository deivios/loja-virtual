import 'package:flutter/material.dart';
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart';
import 'package:lojavirtual/models/page_manager.dart';
import 'package:lojavirtual/screens/products/products_screen.dart';
import 'package:provider/provider.dart';

class BaseScreen extends StatelessWidget {
  final PageController pageController = PageController();

  BaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<PageManager>(
      create: (_) => PageManager(pageController),
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Scaffold(
            backgroundColor: Colors.blueAccent,
            drawer: CustomDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Home', style: TextStyle(color: Colors.white)),
            ),
          ),
          ProductsScreen(),
          Scaffold(
            backgroundColor: Colors.blueAccent,
            drawer: CustomDrawer(),
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              title: const Text('Meus Pedidos', style: TextStyle(color: Colors.white)),
            ),
          ),
          Scaffold(
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
