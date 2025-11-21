import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';
import '../models/user_info.dart';

/// 个人资料页面 - GetX版本
class ProfilePage extends GetView<ProfileController> {
  
  @override
  Widget build(BuildContext context) {
    // 确保控制器已注册
    Get.put(ProfileController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('个人资料'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _showEditDialog(context),
            child: Text('编辑', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        final user = controller.userInfo.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('用户信息加载失败'),
                ElevatedButton(
                  onPressed: controller.loadUserProfile,
                  child: Text('重试'),
                ),
              ],
            ),
          );
        }
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height: 20),
              
              // 头像区域
              _buildAvatarWidget(user),
              
              SizedBox(height: 12),
              Text(
                '点击更换头像',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              
              SizedBox(height: 40),
              
              // 用户信息区域
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('用户名'),
                      subtitle: Text(user.userName ?? '未设置'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _showEditDialog(context),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.badge),
                      title: Text('用户ID'),
                      subtitle: Text(user.userId),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('全名'),
                      subtitle: Text(user.userFullName ?? '未设置'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _showEditDialog(context),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.wc),
                      title: Text('性别'),
                      subtitle: Text(_getSexText(user.sex)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
  
  /// 构建头像显示组件
  Widget _buildAvatarWidget(UserInfo user) {
    return Obx(() {
      final currentUser = controller.userInfo.value ?? user; // 使用响应式数据
      return GestureDetector(
        onTap: controller.isUploading.value ? null : _showImageSourceDialog,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: currentUser.headImage?.isNotEmpty == true
                  ? NetworkImage(currentUser.headImage!)
                  : null,
              backgroundColor: _getAvatarColor(currentUser.userName),
              child: currentUser.headImage?.isEmpty != false
                  ? Text(
                      _getFirstChar(currentUser.userName),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          if (controller.isUploading.value)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
    });
  }
  
  /// 显示编辑对话框
  void _showEditDialog(BuildContext context) {
    final user = controller.userInfo.value;
    if (user == null) return;
    
    final userNameController = TextEditingController(text: user.userName);
    final fullNameController = TextEditingController(text: user.userFullName);
    
    Get.dialog(
      AlertDialog(
        title: Text('编辑个人信息'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userNameController,
              decoration: InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: '全名',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.updateUserInfo(
                userNameController.text.trim(),
                fullNameController.text.trim(),
              );
              Get.back();
            },
            child: Text('保存'),
          ),
        ],
      ),
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
  
  /// 获取性别文本
  String _getSexText(int? sex) {
    switch (sex) {
      case 1:
        return '男';
      case 2:
        return '女';
      default:
        return '未设置';
    }
  }

  /// 安全获取用户名首字符
  String _getFirstChar(String? userName) {
    if (userName == null || userName.isEmpty) {
      return '?';
    }
    return userName.substring(0, 1).toUpperCase();
  }

  /// 显示图片来源选择对话框
  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('选择头像'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('拍照'),
              onTap: () {
                Get.back();
                controller.uploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('从相册选择'),
              onTap: () {
                Get.back();
                controller.uploadAvatar(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 头像展示工具Widget
class AvatarWidget extends StatelessWidget {
  final UserInfo user;
  final double radius;
  final VoidCallback? onTap;
  
  const AvatarWidget({
    Key? key,
    required this.user,
    this.radius = 20,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: user.headImage?.isNotEmpty == true 
            ? NetworkImage(user.headImage!) 
            : null,
        backgroundColor: _getAvatarColor(user.userName),
        child: user.headImage?.isEmpty != false 
            ? Text(
                AvatarWidget._getFirstCharSafe(user.userName),
                style: TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: radius * 0.6,
                ),
              )
            : null,
      ),
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

  /// 安全获取用户名首字符（静态方法）
  static String _getFirstCharSafe(String? userName) {
    if (userName == null || userName.isEmpty) {
      return '?';
    }
    return userName.substring(0, 1).toUpperCase();
  }
}
