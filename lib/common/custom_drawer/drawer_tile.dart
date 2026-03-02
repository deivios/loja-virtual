// ========== DRAWER_TILE.DART - Item do menu lateral ==========
// Ícone + título. Toque -> setPage(). Página atual = azul.

import 'package:flutter/material.dart'; // InkWell, SizedBox, Row, Padding, Icon, Text
import 'package:lojavirtual/models/page_manager.dart'; // PageManager para setPage
import 'package:provider/provider.dart'; // context.watch, context.read

class DrawerTile extends StatelessWidget { // Widget sem estado
  const DrawerTile({super.key, required this.iconData, required this.title, required this.page}); // Construtor

  final IconData iconData; // Ícone (Icons.home, Icons.list, etc.)
  final String title; // Texto do item (Início, Produtos, etc.)
  final int page; // Índice da aba no PageView (0, 1, 2, 3)

  @override
  Widget build(BuildContext context) {
    final curPage = context.watch<PageManager>().page; // Escuta página atual (atualiza ao mudar)
    return InkWell( // Área clicável com efeito ripple
      onTap: () => context.read<PageManager>().setPage(page), // Muda aba e fecha Drawer
      child: SizedBox( // Altura fixa
        height: 60, // 60px de altura
        child: Row( // Ícone à esquerda, texto à direita
          children: [
            Padding( // Margem ao redor do ícone
              padding: const EdgeInsets.symmetric(horizontal: 32), // 32px esquerda e direita
              child: Icon(
                iconData, // Ícone passado no construtor
                size: 32, // Tamanho 32px
                color: curPage == page ? const Color.fromARGB(255, 3, 87, 156) : Colors.grey[700], // Azul RGB(3,87,156) se selecionado, cinza se não
              ),
            ),
            Text( // Título do item
              title, // Texto passado no construtor
              style: TextStyle(
                fontSize: 16, // Fonte 16
                color: curPage == page ? const Color.fromARGB(255, 4, 80, 142) : const Color.fromARGB(255, 97, 97, 97), // Azul RGB(4,80,142) se selecionado, cinza RGB(97,97,97) se não
              ),
            ),
          ],
        ),
      ),
    );
  }
}
