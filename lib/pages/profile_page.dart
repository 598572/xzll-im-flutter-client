import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../models/user_info.dart';

/// 个人资料页面 - GetX版本
class ProfilePage extends GetView<ProfileController> {

  @override
  Widget build(BuildContext context) {
    // 确保控制器已注册
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    
    return Obx(() {
      final currentUser = controller.userInfo.value ?? controller.testUserInfo;
      
      if (currentUser == null) {
        return Scaffold(
          appBar: AppBar(title: Text('个人资料')),
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Text('个人资料'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 20),
              
              // 头像区域
              CircleAvatar(
                radius: 60,
                backgroundImage: currentUser.headImage?.isNotEmpty == true
                    ? NetworkImage(currentUser.headImage!)
                    : null,
                child: currentUser.headImage?.isEmpty != false
                    ? Text(
                        _getFirstChar(currentUser.userName),
                        style: TextStyle(fontSize: 40, color: Colors.white),
                      )
                    : null,
                backgroundColor: _getAvatarColor(currentUser.userName),
              ),
              
              SizedBox(height: 30),
              
              // 用户信息列表
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('用户名'),
                      subtitle: Text(currentUser.userName),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.badge),
                      title: Text('用户ID'),
                      subtitle: Text(currentUser.userId),
                    ),
                    if (currentUser.userFullName?.isNotEmpty == true) ...[
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.person_outline),
                        title: Text('昵称'),
                        subtitle: Text(currentUser.userFullName!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 安全获取用户名首字符
  String _getFirstChar(String? userName) {
    if (userName == null || userName.isEmpty) {
      return '?';
    }
    return userName.substring(0, 1).toUpperCase();
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
}
