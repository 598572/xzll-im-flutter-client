import 'package:flutter/material.dart';
import '../pages/profile_page.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            
            // 账号与安全
            _buildSettingsGroup([
              SettingsItem(
                icon: Icons.person,
                title: '个人信息',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
              SettingsItem(
                icon: Icons.security,
                title: '账号与安全',
                onTap: () => _showComingSoon(context, '账号与安全'),
              ),
              SettingsItem(
                icon: Icons.privacy_tip,
                title: '隐私',
                onTap: () => _showComingSoon(context, '隐私设置'),
              ),
            ]),
            
            SizedBox(height: 20),
            
            // 通用设置
            _buildSettingsGroup([
              SettingsItem(
                icon: Icons.notifications,
                title: '新消息通知',
                onTap: () => _showComingSoon(context, '消息通知'),
              ),
              SettingsItem(
                icon: Icons.chat,
                title: '聊天',
                onTap: () => _showComingSoon(context, '聊天设置'),
              ),
              SettingsItem(
                icon: Icons.language,
                title: '多语言',
                onTap: () => _showComingSoon(context, '多语言'),
              ),
            ]),
            
            SizedBox(height: 20),
            
            // 其他
            _buildSettingsGroup([
              SettingsItem(
                icon: Icons.help,
                title: '帮助与反馈',
                onTap: () => _showComingSoon(context, '帮助与反馈'),
              ),
              SettingsItem(
                icon: Icons.info,
                title: '关于微信',
                onTap: () => _showAboutDialog(context),
              ),
            ]),
            
            SizedBox(height: 40),
            
            // 退出登录按钮
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '退出登录',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  /// 构建设置组
  Widget _buildSettingsGroup(List<SettingsItem> items) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: items.map((item) => _buildSettingsItem(item)).toList(),
      ),
    );
  }
  
  /// 构建设置项
  Widget _buildSettingsItem(SettingsItem item) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.green),
      title: Text(item.title),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: item.onTap,
    );
  }
  
  /// 显示功能开发中提示
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature 功能开发中...')),
    );
  }
  
  /// 显示关于对话框
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '微信',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(Icons.chat, size: 48, color: Colors.green),
      children: [
        Text('这是一个基于Flutter开发的即时通讯应用'),
        SizedBox(height: 10),
        Text('版本: 1.0.0'),
        Text('开发者: 您的团队'),
      ],
    );
  }
  
  /// 显示退出登录对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('退出登录'),
        content: Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 执行退出登录逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('退出登录功能开发中...')),
              );
            },
            child: Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// 设置项数据模型
class SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
