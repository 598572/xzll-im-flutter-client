import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_list_page.dart';
import 'contact_page.dart';
import 'discover_page.dart';
import '../screens/mine/mine_view.dart';

/// 主页面 - 底部导航栏
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    ChatListPage(),
    ContactPage(),
    DiscoverPage(),
    MineView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          // ✅ 禁用重复点击，避免不必要的动画
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        enableFeedback: false, // 禁用触觉反馈
        elevation: 0, // 移除阴影
        backgroundColor: Colors.white, // 固定背景色
        selectedFontSize: 12, // 固定字体大小
        unselectedFontSize: 12, // 固定字体大小
        iconSize: 24, // 固定图标大小
        mouseCursor: SystemMouseCursors.click, // 固定鼠标样式
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: '通讯录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我',
          ),
        ],
      ),
    );
  }
}
