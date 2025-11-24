import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/profile_controller.dart';
import '../../models/user_info.dart';
import '../../constant/custom_log.dart';
import '../../router/router_name.dart';

class MineView extends GetView<ProfileController> {
  const MineView({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 确保控制器已注册，但不重复创建
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
    
    // ✅ 移除自动刷新，只在初始化时从数据库加载
    
    return Scaffold(
      backgroundColor: Color(0xFFEDEDED),
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
        
        return ListView(
          children: [
            SizedBox(height: 20),
            
            // 微信风格的个人信息卡片
            _buildWeChatProfileCard(user),
            
            SizedBox(height: 10),
            
            // 支付功能
            _buildWeChatMenuGroup([
              _buildWeChatMenuItem(
                icon: Icons.payment,
                title: '支付',
                iconBgColor: Color(0xFF09BB07),
                onTap: () => Get.snackbar('提示', '支付功能开发中...'),
              ),
            ]),
            
            SizedBox(height: 10),
            
            // 收藏、朋友圈、卡包、表情
            _buildWeChatMenuGroup([
              _buildWeChatMenuItem(
                icon: Icons.star,
                title: '收藏',
                iconBgColor: Color(0xFFFAAD14),
                onTap: () => Get.snackbar('提示', '收藏功能开发中...'),
              ),
              _buildWeChatMenuItem(
                icon: Icons.camera_alt,
                title: '朋友圈',
                iconBgColor: Color(0xFF576B95),
                onTap: () => Get.snackbar('提示', '朋友圈功能开发中...'),
              ),
              _buildWeChatMenuItem(
                icon: Icons.credit_card,
                title: '卡包',
                iconBgColor: Color(0xFFEE7959),
                onTap: () => Get.snackbar('提示', '卡包功能开发中...'),
              ),
              _buildWeChatMenuItem(
                icon: Icons.emoji_emotions,
                title: '表情',
                iconBgColor: Color(0xFFFAAD14),
                onTap: () => Get.snackbar('提示', '表情功能开发中...'),
              ),
            ]),
            
            SizedBox(height: 10),
            
            // 设置
            _buildWeChatMenuGroup([
              _buildWeChatMenuItem(
                icon: Icons.settings,
                title: '设置',
                iconBgColor: Color(0xFF576B95),
                onTap: () => Get.toNamed(RouterName.settings),
              ),
            ]),
            
            SizedBox(height: 30),
            
            SizedBox(height: 20),
          ],
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
                  ? NetworkImage(
                      '${currentUser.headImage!}?t=${DateTime.now().millisecondsSinceEpoch}',
                    )
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
  
  /// 构建微信风格的个人信息卡片
  Widget _buildWeChatProfileCard(UserInfo user) {
    return Obx(() {
      final currentUser = controller.testUserInfo ?? controller.userInfo.value ?? user; // 优先使用testUserInfo
      return InkWell(
        onTap: () => _showProfileDetail(currentUser),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
            // 头像
            GestureDetector(
              onTap: controller.isUploading.value ? null : _showImageSourceDialog,
              child: Stack(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: currentUser.headImage?.isNotEmpty == true
                      ? NetworkImage(
                          '${currentUser.headImage}?t=${DateTime.now().millisecondsSinceEpoch}',
                        )
                      : null,
                  backgroundColor: _getAvatarColor(currentUser.userName),
                  child: currentUser.headImage?.isEmpty != false
                      ? Text(
                          _getFirstChar(currentUser.userName),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Obx(() => controller.isUploading.value
                    ? Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      )
                    : SizedBox()),
              ],
            ),
          ),
          
          SizedBox(width: 16),
          
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Text(
                    // ✅ 优先使用专用的昵称显示变量，实现无感知更新
                    controller.displayUserFullName.value?.isNotEmpty == true
                        ? controller.displayUserFullName.value!
                        : (currentUser.userFullName?.isNotEmpty == true 
                            ? currentUser.userFullName!
                            : '未设置'),
                    key: ValueKey(controller.displayUserFullName.value ?? currentUser.userFullName ?? '未设置'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                )),
                SizedBox(height: 6),
                Text(
                  '账号: ${currentUser.userName ?? "未设置"}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // 右侧图标
          Row(
            children: [
              Icon(Icons.qr_code_2, color: Colors.grey.shade600, size: 20),
              SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
          ],
        ),
      ),
      );
    });
  }
  
  /// 显示个人资料详情页
  void _showProfileDetail(UserInfo user) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 顶部拖动条
            Container(
              margin: EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 个人信息列表
            _buildDetailItem(
              icon: Icons.person,
              title: '昵称',
              value: user.userFullName ?? '未设置',
              onTap: () {
                Get.back();
                _showEditNicknameDialog(Get.context!);
              },
            ),
            Divider(height: 1, indent: 56),
            _buildDetailItem(
              icon: Icons.badge,
              title: '账号',
              value: user.userName ?? '未设置',
              onTap: null,
            ),
            Divider(height: 1, indent: 56),
            _buildDetailItem(
              icon: Icons.wc,
              title: '性别',
              value: _getSexText(user.sex),
              onTap: null,
            ),
            Divider(height: 1, indent: 56),
            _buildDetailItem(
              icon: Icons.fingerprint,
              title: '用户ID',
              value: user.userId,
              onTap: null,
            ),
            
            SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
  
  /// 构建详情项
  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Colors.grey.shade600),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            if (onTap != null) ...[
              SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 构建微信风格的菜单分组
  Widget _buildWeChatMenuGroup(List<Widget> items) {
    return Container(
      color: Colors.white,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (index < items.length - 1)
                Divider(height: 1, indent: 56, thickness: 0.5),
            ],
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建微信风格的菜单项
  Widget _buildWeChatMenuItem({
    required IconData icon,
    required String title,
    required Color iconBgColor,
    required VoidCallback onTap,
    String? subtitle,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            
            SizedBox(width: 16),
            
            // 标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 右侧内容
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  /// 显示编辑昵称对话框
  void _showEditNicknameDialog(BuildContext context) {
    // ✅ 优先使用testUserInfo，然后是userInfo.value
    final user = controller.testUserInfo ?? controller.userInfo.value;
    if (user == null) return;
    
    // ✅ 优先使用displayUserFullName，然后是user.userFullName
    final currentNickname = controller.displayUserFullName.value ?? user.userFullName ?? '';
    final nicknameController = TextEditingController(text: currentNickname);
    
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('编辑昵称'),
        content: TextField(
          controller: nicknameController,
          decoration: InputDecoration(
            labelText: '昵称',
            hintText: '请输入昵称',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.person_outline),
          ),
          maxLength: 20,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final newNickname = nicknameController.text.trim();
              if (newNickname.isNotEmpty) {
                controller.updateUserInfo(
                  user.userName ?? '', // 用户名不变
                  newNickname, // 只更新昵称
                );
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
