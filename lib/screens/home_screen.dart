/*
import 'package:flutter/material.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';

import '../services/auth_service.dart';
import '../services/websocket_service.dart';
import 'friend_list_screen.dart';
import 'login_screen.dart';
import 'recent_conversations_screen.dart';
import 'user_search_screen.dart';

// 主页屏幕，包含底部导航栏
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final WebSocketService _webSocketService = WebSocketService.instance;

  List<Widget> get _widgetOptions => <Widget>[
    RecentConversationsScreen(),
    const FriendListScreen(),
    _buildDiscoverScreen(),
    _buildProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _setupFriendRequestPushListener();
  }

  /// 设置好友申请推送监听
  void _setupFriendRequestPushListener() {
    _webSocketService.onFriendRequestPush = (FriendRequestPushMessage pushMessage) {
      _handleFriendRequestPush(pushMessage);
    };
  }

  /// 处理好友申请推送
  void _handleFriendRequestPush(FriendRequestPushMessage pushMessage) {
    // 显示推送通知
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                pushMessage.isNewRequest ? Icons.person_add : Icons.notifications,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pushMessage.pushTitle ?? '好友通知',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (pushMessage.pushContent != null) Text(pushMessage.pushContent!),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: pushMessage.isNewRequest ? Colors.purple : Colors.green,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '查看',
            textColor: Colors.white,
            onPressed: () {
              // 跳转到通讯录标签页
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 构建发现页面
  Widget _buildDiscoverScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('发现功能开发中...', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  // 构建个人资料页面
  Widget _buildProfileScreen() {
    final user = _authService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // 用户头像和基本信息
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 头像
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: user?.avatar != null
                      ? ClipOval(child: Image.network(user!.avatar!, fit: BoxFit.cover))
                      : Icon(Icons.person, size: 40, color: Colors.purple),
                ),
                const SizedBox(width: 16),

                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.userName ?? '用户',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '用户ID: ${user?.id ?? 'N/A'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      if (user?.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '手机: ${user!.phone}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),

                // 编辑按钮
                IconButton(
                  onPressed: () {
                    // TODO: 实现个人信息编辑
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('个人信息编辑功能开发中...')));
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.purple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 功能列表
          _buildMenuSection(),

          const SizedBox(height: 24),

          // 设置和登出
          _buildSettingsSection(),
        ],
      ),
    );
  }

  // 构建菜单功能区域
  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: '个人信息',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('个人信息功能开发中...')));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.photo_library_outlined,
            title: '我的相册',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('相册功能开发中...')));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: '收藏',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('收藏功能开发中...')));
            },
          ),
        ],
      ),
    );
  }

  // 构建设置区域
  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: '设置',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('设置功能开发中...')));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: '帮助与反馈',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('帮助功能开发中...')));
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: '退出登录',
            onTap: _handleLogout,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  // 构建菜单项
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[700]),
      title: Text(title, style: TextStyle(fontSize: 16, color: textColor ?? Colors.black87)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  // 构建分割线
  Widget _buildDivider() {
    return Divider(height: 1, color: Colors.grey[200], indent: 16, endIndent: 16);
  }

  // 处理登出
  Future<void> _handleLogout() async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // 执行登出
        await _authService.logout();

        if (mounted) {
          // 跳转到登录页面
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('退出登录失败: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: _selectedIndex == 0
            ? [
                // 聊天页面显示搜索按钮
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('搜索功能开发中...')));
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.add),
                  onSelected: (value) {
                    switch (value) {
                      case 'new_chat':
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('发起聊天功能开发中...')));
                        break;
                      case 'add_friend':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserSearchScreen()),
                        );
                        break;
                      case 'scan_qr':
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('扫码功能开发中...')));
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'new_chat', child: Text('发起聊天')),
                    const PopupMenuItem(value: 'add_friend', child: Text('添加朋友')),
                    const PopupMenuItem(value: 'scan_qr', child: Text('扫一扫')),
                  ],
                ),
              ]
            : null,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return '蝎聊';
      case 1:
        return '通讯录';
      case 2:
        return '发现';
      case 3:
        return '我';
      default:
        return '蝎聊';
    }
  }
}
*/
