import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/user.dart';
import 'package:xzll_im_flutter_client/services/data_base_service.dart';
import '../models/user_info.dart';
import '../services/user_service.dart';
import '../constants/api_constants.dart';

/// 个人信息控制器
class ProfileController extends GetxController {
  // 响应式用户信息
  var userInfo = Rxn<UserInfo>();
  var isLoading = false.obs;
  var isUploading = false.obs;
  
  final ImagePicker _picker = ImagePicker();
  final DataBaseService _dbService = Get.find<DataBaseService>();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    
    // ✅ 监听全局用户信息变化
    _setupUserInfoListener();
  }
  
  /// 设置用户信息监听器
  void _setupUserInfoListener() {
    final AppData appData = Get.find<AppData>();
    
    // 监听全局用户信息变化
    ever(appData.user, (User user) {
      info('🔄 检测到全局用户信息变化，同步更新ProfileController');
      info('📋 新用户信息: ${user.userName} (头像: ${user.avatar})');
      
      // 同步更新本地userInfo
      final currentUserInfo = userInfo.value;
      if (currentUserInfo != null) {
        userInfo.value = currentUserInfo.copyWith(
          headImage: user.avatar,
          userName: user.userName,
          // ✅ 保持原有的userFullName，不要被user.userName覆盖
          // userFullName: user.userName, // 注释掉，避免昵称被用户名覆盖
        );
        info('✅ ProfileController用户信息已同步更新: 头像=${user.avatar}, 用户名=${user.userName}');
        
        // ✅ 强制刷新界面
        userInfo.refresh();
        update();
        
        // ✅ 延迟再次刷新确保完全更新
        Future.delayed(Duration(milliseconds: 50), () {
          userInfo.refresh();
          update();
          info('🔄 监听器延迟刷新完成');
        });
        
      } else {
        // 如果没有本地信息，创建新的
        userInfo.value = UserInfo(
          userId: user.id,
          userName: user.userName,
          userFullName: null, // 保持为null，让界面显示phone
          phone: user.phone, // ✅ 添加手机号
          headImage: user.avatar,
          sex: user.sex ?? -1,
        );
        info('✅ 创建新的ProfileController用户信息');
        
        // ✅ 新创建后也要刷新
        userInfo.refresh();
        update();
      }
    });
  }

  /// 加载用户资料（仅从本地数据库加载，不调用服务器接口）
  Future<void> loadUserProfile() async {
    isLoading.value = true;
    try {
      // ✅ 获取认证信息
      final AppData appData = Get.find<AppData>();
      final User currentUser = appData.user.value;
      
      info('📋 从本地数据库加载用户资料...');
      info('📋 当前用户: ${currentUser.userName} (ID: ${currentUser.id})');
      
      // ✅ 优先从本地数据库加载用户信息
      UserInfo? localUserInfo = await _dbService.getUserInfo(currentUser.id);
      if (localUserInfo != null) {
        userInfo.value = localUserInfo;
        info('✅ 从本地数据库加载用户信息成功: ${localUserInfo.userFullName ?? "未设置"} (${localUserInfo.userName})');
      } else {
        // 如果本地没有，使用基础信息创建
        userInfo.value = UserInfo(
          userId: currentUser.id,
          userName: currentUser.userName,
          userFullName: null, // 昵称为空
          phone: currentUser.phone,
          headImage: currentUser.avatar,
          sex: currentUser.sex ?? -1,
        );
        info('✅ 使用全局用户信息初始化完成');
        
        // ✅ 保存基础信息到数据库
        await _dbService.saveUserInfo(userInfo.value!);
        info('💾 基础用户信息已保存到本地数据库');
      }
      
    } catch (e, stackTrace) {
      error('❌ 加载用户资料失败: $e');
      error('❌ 堆栈跟踪: $stackTrace');
      Get.snackbar('错误', '加载用户信息失败: $e');
      
      // ✅ 设置默认用户信息以便界面显示
      final AppData appData = Get.find<AppData>();
      final User currentUser = appData.user.value;
      
      userInfo.value = UserInfo(
        userId: currentUser.id.isNotEmpty ? currentUser.id : 'unknown',
        userName: currentUser.userName.isNotEmpty ? currentUser.userName : '未知用户',
        userFullName: null, // 保持为null，让界面显示phone
        phone: currentUser.phone, // ✅ 添加手机号
        headImage: currentUser.avatar,
        sex: -1,
      );
    } finally {
      isLoading.value = false;
      info('📋 用户资料加载完成');
    }
  }

  /// 从服务器同步用户信息（仅在更新操作后调用）
  Future<void> syncUserInfoFromServer() async {
    try {
      final AppData appData = Get.find<AppData>();
      final String token = appData.token.value;
      
      if (token.isEmpty) {
        error('❌ Token为空，无法同步服务器数据');
        return;
      }
      
      info('📤 从服务器同步用户信息...');
      final response = await http.get(
        Uri.parse(ApiConstants.getUserProfile),
        headers: appData.getAuthHeaders(),
      );
      
      info('📥 服务器响应状态: ${response.statusCode}');
      info('📥 服务器响应内容: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['code'] == 1 && responseData['data'] != null) {
          final Map<String, dynamic> userData = responseData['data'];
          final serverUserInfo = UserInfo.fromJson(userData);
          userInfo.value = serverUserInfo;
          info('✅ 从服务器同步用户信息成功');
          
          // ✅ 保存到本地数据库
          await _dbService.saveUserInfo(serverUserInfo);
          info('💾 同步的用户信息已保存到本地数据库');
          
          // ✅ 刷新界面
          userInfo.refresh();
          update();
        } else {
          error('❌ 服务器返回格式异常: ${responseData}');
        }
      } else {
        error('❌ 服务器请求失败，状态码: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      error('❌ 同步服务器用户信息失败: $e');
      error('❌ 堆栈跟踪: $stackTrace');
    }
  }

  /// 上传头像（由UI层调用，传入ImageSource）
  Future<void> uploadAvatar(ImageSource source) async {
    try {
      // ✅ 获取当前用户信息
      final AppData appData = Get.find<AppData>();
      final String currentUserId = appData.user.value.id;
      
      info('📷 开始头像上传流程...');
      info('📋 当前用户ID: $currentUserId');
      info('📋 用户信息状态: ${userInfo.value?.toString() ?? "null"}');
      
      if (currentUserId.isEmpty) {
        error('❌ 当前用户ID为空，无法上传头像');
        Get.snackbar('错误', '用户未登录，请重新登录');
        return;
      }
      
      // 选择图片
      info('📷 打开图片选择器...');
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image == null) {
        info('📷 用户取消图片选择');
        return;
      }
      
      info('📷 图片选择成功: ${image.path}');
      info('📋 图片名称: ${image.name}');

      // 上传头像
      isUploading.value = true;
      info('📤 开始上传头像文件...');
      
      final String? avatarUrl = await UserService.uploadAvatar(
        File(image.path), // 只传文件，用户ID从Token自动获取
      );

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        info('头像上传成功，URL: $avatarUrl');
        
        // 第一步：立即更新本地用户信息
        final currentUserInfo = userInfo.value;
        if (currentUserInfo != null) {
          userInfo.value = currentUserInfo.copyWith(headImage: avatarUrl);
          info('本地UserInfo已更新: ${userInfo.value?.headImage}');
        }
        
        // 第二步：同步更新全局用户信息
        final currentUser = appData.user.value;
        appData.user.value = User(
          id: currentUser.id,
          userName: currentUser.userName,
          phone: currentUser.phone,
          sex: currentUser.sex,
          avatar: avatarUrl, // 更新头像URL
          createTime: currentUser.createTime,
        );
        await appData.saveAuthState();
        info('全局User已更新: ${appData.user.value.avatar}');
        
        // 第三步：多重刷新确保界面更新
        userInfo.refresh(); // 强制触发Obx更新
        update(); // 强制触发GetBuilder更新
        
        // ✅ 第四步：保存到本地数据库
        if (userInfo.value != null) {
          await _dbService.saveUserInfo(userInfo.value!);
          info('💾 头像更新已保存到本地数据库');
        }
        
        // ✅ 第五步：从服务器同步最新用户信息
        await syncUserInfoFromServer();
        
        Get.snackbar('成功', '头像上传成功');
        info('✅ 头像更新流程完成');
      } else {
        error('头像上传返回空URL');
        Get.snackbar('失败', '头像上传失败，请重试');
      }
    } catch (e, stackTrace) {
      error('上传头像异常: $e');
      error('堆栈跟踪: $stackTrace');
      error('❌ 堆栈跟踪: $stackTrace');
      Get.snackbar('错误', '上传头像失败: $e');
    } finally {
      isUploading.value = false;
      info('📤 头像上传流程结束');
    }
  }


  /// 更新用户信息
  Future<void> updateUserInfo(String userName, String userFullName) async {
    try {
      isLoading.value = true;
      
      // ✅ 获取认证信息
      final AppData appData = Get.find<AppData>();
      final String token = appData.token.value;
      
      if (token.isEmpty) {
        throw Exception('用户未登录，请重新登录');
      }
      
      // 构建请求数据（不需要userId，服务器从Token获取）
      final updateData = {
        'userName': userName,
        'userFullName': userFullName,
      };
      
      // 调用更新用户信息API（带Token认证）
      final response = await http.put(
        Uri.parse(ApiConstants.updateUserProfile),
        headers: {
          ...appData.getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );
      
      if (response.statusCode == 200) {
        try {
          final responseText = response.body;
          info('✅ 更新用户信息成功，响应内容: $responseText');
          
          // ✅ 第一步：立即更新本地用户信息
          final currentUserInfo = userInfo.value;
          if (currentUserInfo != null) {
            userInfo.value = currentUserInfo.copyWith(
              userName: userName,
              userFullName: userFullName, // 更新昵称
            );
            info('✅ 本地UserInfo已更新: 昵称=${userInfo.value?.userFullName}, 用户名=${userInfo.value?.userName}');
          }
          
          // ✅ 第二步：尝试解析服务器响应（可选）
          try {
            final Map<String, dynamic> updatedUserData = json.decode(responseText);
            info('✅ 解析后的JSON数据: $updatedUserData');
            
            // 如果服务器返回了完整数据，使用服务器数据
            if (updatedUserData['code'] == 1 && updatedUserData['data'] != null) {
              userInfo.value = UserInfo.fromJson(updatedUserData['data']);
              info('✅ 使用服务器返回的用户信息');
            }
          } catch (e) {
            info('⚠️ 服务器响应解析失败，使用本地更新: $e');
          }
          
          // ✅ 第三步：同步更新全局用户信息
          final currentUser = appData.user.value;
          appData.user.value = User(
            id: currentUser.id,
            userName: userName, // 更新用户名
            phone: currentUser.phone,
            sex: currentUser.sex,
            avatar: currentUser.avatar,
            createTime: currentUser.createTime,
          );
          await appData.saveAuthState();
          info('✅ 全局User已更新: ${appData.user.value.userName}');
          
          // ✅ 第四步：多重刷新确保界面更新
          userInfo.refresh(); // 强制触发Obx更新
          update(); // 强制触发GetBuilder更新
          
          // ✅ 第五步：保存到本地数据库
          if (userInfo.value != null) {
            await _dbService.saveUserInfo(userInfo.value!);
            info('💾 昵称更新已保存到本地数据库');
          }
          
          // ✅ 第六步：从服务器同步最新用户信息
          await syncUserInfoFromServer();
          
          Get.snackbar('成功', '信息更新成功');
          info('✅ 昵称更新流程完成');
        } catch (e, stackTrace) {
          error('❌ 处理更新响应时出错: $e');
          error('❌ 堆栈跟踪: $stackTrace');
          Get.snackbar('错误', '处理响应数据失败: $e');
        }
      } else {
        error('❌ 更新用户信息失败，状态码: ${response.statusCode}');
        error('❌ 响应内容: ${response.body}');
        throw Exception('更新失败: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('错误', '更新失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
