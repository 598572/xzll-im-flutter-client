import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_page.dart';
import '../constant/app_data.dart';
import '../services/auth_service.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('退出登录'),
        content: Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout(context);
            },
            child: Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// 处理退出登录
  Future<void> _handleLogout(BuildContext context) async {
    try {
      // ✅ 显示加载提示
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在退出登录...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      // ✅ 调用服务器登出API
      final bool logoutSuccess = await AuthService.logout();
      
      // ✅ 关闭加载对话框
      Get.back();
      
      if (logoutSuccess) {
        // ✅ 服务器登出成功，清除本地数据
        final AppData appData = Get.find<AppData>();
        appData.clearAuthState();
        
        // ✅ 跳转到登录页面
        Get.offAllNamed('/login');
        
        Get.snackbar(
          '成功', 
          '已退出登录',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // ✅ 服务器登出失败，但仍然清除本地数据
        final AppData appData = Get.find<AppData>();
        appData.clearAuthState();
        
        Get.offAllNamed('/login');
        
        Get.snackbar(
          '警告', 
          '服务器登出失败，但已清除本地登录状态',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // ✅ 关闭可能存在的加载对话框
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      Get.snackbar(
        '错误', 
        '退出登录失败: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
