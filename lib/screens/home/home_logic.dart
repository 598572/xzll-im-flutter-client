import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeLogic extends GetxService {
  final PageController pageController = PageController();

  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }
}
