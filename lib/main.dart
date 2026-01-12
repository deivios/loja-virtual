import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/firebase_options.dart';
import 'package:lojavirtual/models/user_manager.dart';
import 'package:lojavirtual/screens/base/base_screen.dart';
import 'package:lojavirtual/screens/screens.signup/signup_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase com o projeto loja-virtual-8d7f7
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
  
  // Listener para monitorar mudanças no documento do Firestore
  FirebaseFirestore.instance.collection('boletos').snapshots().listen((snapshot){    
    for(DocumentSnapshot document in snapshot.docs){  
      print(document.data());
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(                           // Fornece o UserManager para toda a árvore de widgets abaixo
      create: (_) => UserManager(),            // Cria uma instância nova do UserManager quando o app inicia
      child: MaterialApp(                      // Widget raiz do app Flutter (configura tema, rotas, etc.)
        debugShowCheckedModeBanner: false,     // Remove a faixa vermelha "DEBUG" no canto superior direito
        theme: ThemeData(                      // Define o tema visual geral do aplicativo
          colorScheme: ColorScheme.fromSeed(   // Gera paleta de cores automática a partir de uma cor base
            seedColor: const Color.fromARGB(255, 36, 103, 205), // Cor principal (azul médio)
          ),
        ),
        color: Colors.blue,                    // Cor principal do app (usada em alguns elementos nativos)
        initialRoute:  '/base',
        onGenerateRoute: (settings) {          // Define rotas dinâmicas (chamado quando usa Navigator.pushNamed)
          switch (settings.name) {             // Verifica o nome da rota solicitada
            case '/base':                      // Rota para a tela principal (base)
              return MaterialPageRoute(
                builder: (_) => BaseScreen(),  // Retorna a BaseScreen quando a rota é '/base'
              );
            
            case '/signup':                    // Rota para tela de cadastro
              return MaterialPageRoute(
                builder: (_) => SigUpScreen(), // Retorna SigUpScreen
              );
            
            default:                           // Caso a rota não exista (fallback)
              return MaterialPageRoute(
                builder: (_) => BaseScreen(),  // Volta para a tela base como padrão
              );
          }
        },
      ),
    );
  }
}
