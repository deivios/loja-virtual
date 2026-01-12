import 'package:flutter/cupertino.dart';

class PageManager {
  // Construtor: recebe o PageController que controla o PageView
  PageManager(this.pageController);

  final PageController pageController;

  // Guarda o índice da página atual (começa em 0)
  int page = 0;

  // Método para mudar de página
  void setPage(int newPage) {
    if (newPage == page) return; // Se já está na mesma página, não faz nada

    page = newPage;              // Atualiza o número da página atual
    pageController.jumpToPage(newPage); // Muda a tela no PageView
  }
}