// ========== PAGE_MANAGER.DART - Controla PageView ==========
// Sincroniza índice com PageController. Drawer chama setPage().

import 'package:flutter/cupertino.dart'; // PageController

class PageManager {
  PageManager(
    this.pageController,
  ); // Construtor - recebe controller da BaseScreen
  final PageController pageController; // Referência ao controller do PageView
  int page =
      0; // Índice da página atual (0=Home, 1=Produtos, 2=Pedidos, 3=Lojas)

  void setPage(int newPage) {
    // Muda para outra aba (chamado pelo DrawerTile)
    if (newPage == page) {
      return; // Já está na mesma página, evita chamada desnecessária
    }
    page = newPage; // Atualiza índice guardado
    pageController.jumpToPage(
      newPage,
    ); // Faz PageView pular para a página (sem animação)
  }
}
