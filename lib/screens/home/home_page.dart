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
      body: Obx(() {
        // ✅ 使用IndexedStack替代PageView，禁止滑动切换
        return IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const ConversationView(),
            const ContactsView(),
            const DiscoverView(),
            const MineView(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          enableFeedback: false, // 禁用触觉反馈
          elevation: 0, // 移除阴影
          backgroundColor: Colors.white, // 固定背景色
          selectedFontSize: 12, // 固定字体大小
          unselectedFontSize: 12, // 固定字体大小
          iconSize: 24, // 固定图标大小
          mouseCursor: SystemMouseCursors.click, // 固定鼠标样式
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
