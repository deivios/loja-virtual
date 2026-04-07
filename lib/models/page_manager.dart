import 'package:flutter/widgets.dart';

class PageManager extends ChangeNotifier {
  PageManager(this.pageController);

  final PageController pageController;
  int page = 0;

  void setPage(int newPage) {
    if (newPage == page) return;
    page = newPage;
    pageController.jumpToPage(newPage);
    notifyListeners();
  }
}
