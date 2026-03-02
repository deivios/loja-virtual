// ========== MAIN.DART - Ponto de entrada do aplicativo Flutter ==========
// Este arquivo é executado quando o app inicia. Configura Firebase, Providers e rotas.

import 'package:firebase_core/firebase_core.dart'; // Firebase Core - inicialização
import 'package:flutter/material.dart'; // Widgets Material (Scaffold, AppBar, MaterialApp, etc.)
import 'package:lojavirtual/firebase_options.dart'; // DefaultFirebaseOptions - configs por plataforma
import 'package:lojavirtual/models/page_manager.dart'; // PageManager - controla índice do PageView
import 'package:lojavirtual/models/cart_manager.dart'; // CartManager - gerencia carrinho
import 'package:lojavirtual/models/product.dart'; // Product - modelo para rota /product
import 'package:lojavirtual/models/product_manager.dart'; // ProductManager - lista produtos
import 'package:lojavirtual/models/user_manager.dart'; // UserManager - login, cadastro, logout
import 'package:lojavirtual/screens/base/base_screen.dart'; // BaseScreen - tela principal com abas
import 'package:lojavirtual/screens/cart_screen.dart'; // CartScreen - tela do carrinho
import 'package:lojavirtual/screens/login_screen.dart'; // LoginScreen - tela de login
import 'package:lojavirtual/screens/product/product_screen.dart'; // ProductScreen - detalhes do produto
import 'package:lojavirtual/screens/debug/money_simulator_screen.dart'; // MoneySimulatorScreen - demo
import 'package:lojavirtual/screens/screens.signup/signup_screen.dart'; // SigUpScreen - cadastro
import 'package:provider/provider.dart'; // MultiProvider, Provider, ChangeNotifierProvider

void main() async {
  // Função principal - async permite await
  WidgetsFlutterBinding.ensureInitialized(); // Obrigatório antes de async: binding nativo pronto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inicializa Firebase
  runApp(const MyApp()); // Inicia o app com widget raiz
}

class MyApp extends StatelessWidget {
  // Widget raiz do app
  const MyApp({super.key}); // Construtor - super.key para identificação

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Fornece vários objetos globais (qualquer filho acessa)
      providers: [
        Provider(
          create: (_) => UserManager(),
          lazy: false,
        ), // UserManager - lazy: false = cria ao iniciar
        Provider(
          create: (_) => PageManager(PageController()),
          lazy: false,
        ), // PageManager - Drawer usa setPage
        ChangeNotifierProvider(
          create: (_) => ProductManager(),
          lazy: false,
        ), // ProductManager - escuta Firestore
        ChangeNotifierProxyProvider<UserManager, CartManager>(
          // CartManager depende de UserManager
          create: (_) => CartManager(), // Cria na primeira vez
          update: (_, userManager, cartManager) {
            final manager =
                cartManager ?? CartManager(); // Reutiliza ou cria novo
            manager.updateUser(userManager); // Atualiza user ao login/logout
            return manager;
          },
        ),
      ],
      child: MaterialApp(
        // App Material Design
        debugShowCheckedModeBanner: false, // Remove faixa "DEBUG" no canto
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 36, 103, 205),
          ), // Azul - gera paleta
        ),
        color: Colors.blue, // Cor da barra de status
        initialRoute: '/base', // Rota inicial ao abrir
        onGenerateRoute: (settings) {
          // Chamado ao pushNamed
          switch (settings.name) {
            case '/login':
              return MaterialPageRoute(
                builder: (_) => LoginScreen(),
              ); // Tela de login
            case '/base':
              return MaterialPageRoute(
                builder: (_) => BaseScreen(),
              ); // Tela principal com abas
            case '/signup':
              return MaterialPageRoute(
                builder: (_) => SigUpScreen(),
              ); // Tela de cadastro
            case '/product':
              return MaterialPageRoute(
                builder: (_) => ProductScreen(
                  settings.arguments as Product,
                ), // Detalhes - Product vem de arguments
              );
            case '/cart':
              return MaterialPageRoute(
                builder: (_) => CartScreen(),
              ); // Tela do carrinho
            case '/money-sim':
              return MaterialPageRoute(
                builder: (_) => const MoneySimulatorScreen(),
              ); // Demo formatCompactPtBr
            default:
              return MaterialPageRoute(
                builder: (_) => BaseScreen(),
              ); // Fallback se rota desconhecida
          }
        },
      ),
    );
  }
}
