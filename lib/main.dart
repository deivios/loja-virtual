import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/firebase_options.dart';
import 'package:lojavirtual/screens/base/base_screen.dart';
import 'package:lojavirtual/screens/login_screen.dart';


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
    return MaterialApp(
       debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 36, 103, 205)),
      ),
      color: Colors.blue,
          home: BaseScreen(

          ),
    );
  }
}

