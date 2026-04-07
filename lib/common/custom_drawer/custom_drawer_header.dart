// ========== CUSTOM_DRAWER_HEADER.DART - Cabeçalho do Drawer ==========
// Nome loja, "Olá, [nome]", Sair/Entrar. Sair -> signOut. Entrar -> /login.

import 'package:flutter/material.dart'; // Container, Column, Text, GestureDetector
import 'package:lojavirtual/models/user_manager.dart'; // UserManager para login/logout
import 'package:provider/provider.dart'; // context.read

class CustomDrawerHeader extends StatelessWidget { // Widget sem estado
  const CustomDrawerHeader({super.key}); // Construtor

  @override
  Widget build(BuildContext context) {
    final userManager = context.watch<UserManager>(); // Escuta UserManager (login, signOut)
    return Container( // Container com padding
      padding: const EdgeInsets.fromLTRB(32, 24, 16, 8), // left 32, top 24, right 16, bottom 8
      child: Column( // Coluna vertical
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha filhos à esquerda
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Espaça filhos verticalmente
        children: [
          Text('Loja do \nVinicius', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)), // Nome da loja, fonte 34, negrito
          const SizedBox(height: 16), // Espaço de 16px
          Text( // Saudação com nome do usuário
            'Olá, ${userManager.user?.name ?? ''}', // user?.name ou '' se null
            overflow: TextOverflow.ellipsis, // Corta com "..." se longo
            maxLines: 2, // Máximo 2 linhas
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Fonte 18, negrito
          ),
          const SizedBox(height: 8), // Espaço de 8px
          GestureDetector( // Área clicável
            onTap: () async { // Ao tocar
              if (userManager.isLoggedIn) { // Se logado
                await userManager.signOut(); // Faz logout
                if (context.mounted) Navigator.of(context).pop(); // Fecha o Drawer
              } else { // Se deslogado
                Navigator.of(context).pop(); // Fecha o Drawer
                Navigator.of(context).pushNamed('/login'); // Abre tela de login
              }
            },
            child: Text( // Texto clicável
              userManager.isLoggedIn ? 'Sair' : 'Entre ou cadastre-se >', // Mostra Sair ou Entrar
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 4, 80, 142)), // Azul escuro RGB(4,80,142)
            ),
          ),
        ],
      ),
    );
  }
}
