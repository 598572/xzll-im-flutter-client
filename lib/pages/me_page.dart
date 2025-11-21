import 'package:flutter/material.dart';
import 'dart:developer';
import '../models/user_info.dart';
import '../config/api_config.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';

/// "我的"页面 - 个人信息模块主入口
class MePage extends StatefulWidget {
  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  UserInfo? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      // TODO: 从缓存或服务端获取用户信息
      setState(() {
        currentUser = UserInfo(
          userId: ApiConfig.currentUserId ?? 'demo_user',
          userName: '张三', // 示例数据
          userFullName: '张三丰',
          headImage: null, // 暂无头像
          sex: 1,
        );
      });
    } catch (e) {
      log('加载用户信息失败: $e');
    }
  }

  /// 构建个人信息卡片
  Widget _buildProfileCard() {
    if (currentUser == null) {
      return Card(
        margin: EdgeInsets.all(16),
        child: Container(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // 头像
              CircleAvatar(
                radius: 30,
                backgroundImage: currentUser!.headImage?.isNotEmpty == true
                    ? NetworkImage(currentUser!.headImage!)
                    : null,
                backgroundColor: _getAvatarColor(currentUser!.userName),
                child: currentUser!.headImage?.isEmpty != false
                    ? Text(
                        _getFirstChar(currentUser!.userName),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              
              SizedBox(width: 16),
              
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser!.userName ?? '未知用户',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '微信号: ${currentUser!.userId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 箭头
              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建功能菜单
  Widget _buildMenuList() {
    final menuItems = [
      MenuItemData(
        icon: Icons.payment,
        title: '支付',
        onTap: () => _showComingSoon('支付'),
      ),
      MenuItemData(
        icon: Icons.star,
        title: '收藏',
        onTap: () => _showComingSoon('收藏'),
      ),
      MenuItemData(
        icon: Icons.photo_album,
        title: '朋友圈',
        onTap: () => _showComingSoon('朋友圈'),
      ),
      MenuItemData(
        icon: Icons.card_giftcard,
        title: '卡包',
        onTap: () => _showComingSoon('卡包'),
      ),
      MenuItemData(
        icon: Icons.emoji_emotions,
        title: '表情',
        onTap: () => _showComingSoon('表情'),
      ),
      MenuItemData(
        icon: Icons.settings,
        title: '设置',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        },
      ),
    ];

    return Column(
      children: [
        // 第一组菜单
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: menuItems.take(4).map((item) => _buildMenuItem(item)).toList(),
          ),
        ),
        
        // 第二组菜单
        Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: menuItems.skip(4).map((item) => _buildMenuItem(item)).toList(),
          ),
        ),
      ],
    );
  }

  /// 构建单个菜单项
  Widget _buildMenuItem(MenuItemData item) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.green),
      title: Text(item.title),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: item.onTap,
    );
  }

  /// 显示功能开发中提示
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature 功能开发中...')),
    );
  }

  /// 根据用户名生成头像背景色
  Color _getAvatarColor(String? userName) {
    if (userName?.isEmpty != false) return Colors.grey;
    
    final colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.red, Colors.teal, Colors.indigo, Colors.pink,
    ];
    
    final index = userName!.hashCode.abs() % colors.length;
    return colors[index];
  }

  /// 安全获取用户名首字符
  String _getFirstChar(String? userName) {
    if (userName == null || userName.isEmpty) {
      return '?';
    }
    return userName.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildProfileCard(),
              SizedBox(height: 20),
              _buildMenuList(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// 菜单项数据模型
class MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
