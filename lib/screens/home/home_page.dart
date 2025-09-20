import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/screens/contacts/contacts_view.dart';
import 'package:xzll_im_flutter_client/screens/conversation/conversation_view.dart';
import 'package:xzll_im_flutter_client/screens/discover/discover_view.dart';
import 'package:xzll_im_flutter_client/screens/home/home_logic.dart';
import 'package:xzll_im_flutter_client/screens/mine/mine_view.dart';

class HomePage extends GetView<HomeLogic> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          const ConversationView(),
          const ContactsView(),
          const DiscoverView(),
          const MineView(),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
            BottomNavigationBarItem(icon: Icon(Icons.contacts), label: '通讯录'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: '发现'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '我'),
          ],
        );
      }),
    );
  }
}
