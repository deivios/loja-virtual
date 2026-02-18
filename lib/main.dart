import 'package:firebase_core/firebase_core.dart';           // Pacote principal para inicializar o Firebase no app
import 'package:flutter/material.dart';                      // Pacote principal do Flutter (widgets, temas, MaterialApp, etc.)
// import 'package:flutter/foundation.dart';
import 'package:lojavirtual/firebase_options.dart';         // Arquivo gerado pelo FlutterFire CLI com as configurações do seu projeto Firebase
import 'package:lojavirtual/models/page_manager.dart';       // Gerenciador de páginas (controla o PageView da BaseScreen)
import 'package:lojavirtual/models/product.dart';
import 'package:lojavirtual/models/product_manager.dart';    // Gerenciador de produtos (carrega produtos do Firestore)
import 'package:lojavirtual/models/user_manager.dart';       // Gerenciador de usuário (login, logout, dados do usuário logado)
import 'package:lojavirtual/screens/base/base_screen.dart';  // Tela base com PageView e Drawer (menu lateral)
import 'package:lojavirtual/screens/login_screen.dart';      // Tela de login
import 'package:lojavirtual/screens/product/product_screen.dart';
import 'package:lojavirtual/screens/debug/money_simulator_screen.dart';
import 'package:lojavirtual/screens/screens.signup/signup_screen.dart'; // Tela de cadastro (signup)
import 'package:provider/provider.dart';                     // Pacote de gerenciamento de estado (Provider)

void main() async {                                          // Função principal do app – async porque inicializa Firebase
  WidgetsFlutterBinding.ensureInitialized();                 // Garante que o Flutter está pronto antes de rodar código async (obrigatório antes do Firebase)
  
  // Inicializa o Firebase com as opções do seu projeto (loja-virtual-8d7f7)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,       // Usa as configs geradas automaticamente pelo FlutterFire CLI
  );
  
  runApp(const MyApp());                                     // Inicia o app Flutter passando o widget raiz (MyApp)
  
  // Listener permanente no Firestore para monitorar a coleção 'boletos' em tempo real
  // Toda vez que houver mudança (novo boleto, atualização, exclusão), o callback é chamado
  // Removido o listener de 'boletos' para evitar spam/erro de permissão no console.
}

class MyApp extends StatelessWidget {                        // Widget raiz do aplicativo (sem estado)
  const MyApp({super.key});                                  // Construtor constante (boa prática para performance)

  @override
  Widget build(BuildContext context) {                       // Método que constrói a interface
    return MultiProvider(                                    // Fornece múltiplos gerenciadores de estado para toda a árvore de widgets
      providers: [                                           // Lista de providers disponíveis em qualquer lugar do app
        Provider(                                            // Provider simples (não ChangeNotifier) para UserManager
          create: (_) => UserManager(),                      // Cria instância do UserManager
          lazy: false,                                       // Carrega imediatamente (não espera ser usado)
        ),
        Provider(                                            // Provider para PageManager
          create: (_) => PageManager(PageController()),  
          lazy: false,  // Cria PageManager passando um PageController novo
        ),
        ChangeNotifierProvider(                              // ProductManager é ChangeNotifier, então precisa desse provider
          create: (_) => ProductManager(),                   // Cria instância do ProductManager
          lazy: false,                                       // Carrega imediatamente (ex: já faz fetch dos produtos)
        ),
      ],
      child: MaterialApp(                                    // Widget raiz do Material Design – configura tema, rotas, etc.
        debugShowCheckedModeBanner: false,                   // Remove a faixa vermelha "DEBUG" no canto superior direito
        theme: ThemeData(                                    // Define o tema visual geral do aplicativo
          colorScheme: ColorScheme.fromSeed(                 // Gera paleta de cores automática a partir de uma cor base
            seedColor: const Color.fromARGB(255, 36, 103, 205), // Azul médio como cor principal (seed)
          ),
        ),
        color: Colors.blue,                                  // Cor principal do app (usada em alguns elementos nativos como status bar)
        initialRoute: '/base',                               // Rota inicial quando o app abre (vai direto para BaseScreen)
        onGenerateRoute: (settings) {                        // Função chamada toda vez que usa Navigator.pushNamed
          switch (settings.name) {                           // Verifica qual rota foi solicitada
            case '/login':                                   // Rota para tela de login
              return MaterialPageRoute(
                builder: (_) => LoginScreen(),               // Constrói a tela de login
              );
            case '/base':                                    // Rota para tela principal (com PageView)
              return MaterialPageRoute(
                builder: (_) => BaseScreen(),                // Constrói a BaseScreen
              );
            case '/signup':                                  // Rota para tela de cadastro
              return MaterialPageRoute(
                builder: (_) => SigUpScreen(),               // Constrói a tela de signup (cadastro)
              );
              case '/product':                                  // Rota para tela de cadastro
              return MaterialPageRoute(
                builder: (_) => ProductScreen(
                  settings.arguments as Product
                ),               // Constrói a tela de signup (cadastro)
              );
            case '/money-sim':
              return MaterialPageRoute(
                builder: (_) => const MoneySimulatorScreen(),
              );
            default:                                         // Caso a rota não exista (fallback)
              return MaterialPageRoute(
                builder: (_) => BaseScreen(),                // Volta para a tela base como padrão
              );
          }
        },
      ),
    );
  }
}