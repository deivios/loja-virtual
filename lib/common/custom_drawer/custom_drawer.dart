// ========== CUSTOM_DRAWER.DART - Menu lateral ==========
// Desliza da esquerda. Cabeçalho + itens. Cada item chama setPage().

import 'package:flutter/material.dart'; // Drawer, Stack, Container, ListView, Divider
import 'package:lojavirtual/common/custom_drawer/custom_drawer_header.dart'; // Cabeçalho com nome e Sair/Entrar
import 'package:lojavirtual/common/custom_drawer/drawer_tile.dart'; // Item clicável do menu

class CustomDrawer extends StatelessWidget { // Widget sem estado
  const CustomDrawer({super.key}); // Construtor

  @override
  Widget build(BuildContext context) {
    return Drawer( // Menu lateral que desliza da esquerda
      child: Stack( // Empilha gradiente (fundo) + ListView (conteúdo)
        children: [
          Container( // Camada 1: fundo com gradiente
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, // Começa no topo
                end: Alignment.bottomCenter, // Termina embaixo
                colors: [Color.fromARGB(255, 214, 236, 250), Colors.white], // Azul claro RGB(214,236,250) -> branco
              ),
            ),
          ),
          ListView( // Camada 2: conteúdo rolável
            children: [
              CustomDrawerHeader(), // Nome loja, Olá [nome], Sair/Entrar
              const Divider(), // Linha horizontal separadora
              DrawerTile(iconData: Icons.home, title: 'Início', page: 0), // Aba 0 = Home
              DrawerTile(iconData: Icons.list, title: 'Produtos', page: 1), // Aba 1 = Produtos
              DrawerTile(iconData: Icons.playlist_add_check, title: 'Meus Pedidos', page: 2), // Aba 2 = Meus Pedidos
              DrawerTile(iconData: Icons.location_on, title: 'Lojas', page: 3), // Aba 3 = Lojas
            ],
          ),
        ],
      ),
    );
  }
}
