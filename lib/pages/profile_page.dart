import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../models/user_info.dart';

/// 个人资料页面 - GetX版本
class ProfilePage extends GetView<ProfileController> {

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  /// 加载用户信息
  Future<void> _loadUserInfo() async {
    try {
      // TODO: 从服务端或本地获取当前用户信息
      setState(() {
        currentUser = UserInfo(
          userId: ApiConfig.currentUserId ?? '',
          userName: '用户名称', // 从实际数据获取
          headImage: null, // 当前没有头像
        );
      });
    } catch (e) {
      log('加载用户信息失败: $e');
    }
  }

  /// 选择并上传头像
  Future<void> _selectAndUploadAvatar() async {
    try {
      // 1. 显示选择来源对话框
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      // 2. 选择图片
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image == null) return;

      // 3. 上传头像
      setState(() {
        isUploading = true;
      });

      final String? avatarUrl = await UserService.uploadAvatar(
        File(image.path),
        currentUser!.userId,
      );

      if (avatarUrl != null) {
        setState(() {
          currentUser = currentUser!.copyWith(headImage: avatarUrl);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('头像上传成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('头像上传失败，请重试')),
        );
      }
    } catch (e) {
      log('上传头像失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上传失败: $e')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  /// 显示图片来源选择对话框
  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('选择头像'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('拍照'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建头像显示组件
  Widget _buildAvatarWidget() {
    return GestureDetector(
      onTap: isUploading ? null : _selectAndUploadAvatar,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: currentUser?.headImage?.isNotEmpty == true
                ? NetworkImage(currentUser!.headImage!)
                : null,
            backgroundColor: Colors.blue,
            child: currentUser?.headImage?.isEmpty != false
                ? Text(
                    _getFirstChar(currentUser?.userName),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          if (isUploading)
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
            _buildAvatarWidget(),
            
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
                    subtitle: Text(currentUser!.userName),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.badge),
                    title: Text('用户ID'),
                    subtitle: Text(currentUser!.userId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 头像展示工具类
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
                AvatarWidget._getFirstCharFromName(user.userName),
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
  static String _getFirstCharFromName(String? userName) {
    if (userName == null || userName.isEmpty) {
      return '?';
    }
    return userName.substring(0, 1).toUpperCase();
  }
}
