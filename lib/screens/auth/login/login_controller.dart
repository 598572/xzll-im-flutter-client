import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/api/user_api.dart';
import 'package:xzll_im_flutter_client/config/api_config.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/api_response.dart';
import 'package:xzll_im_flutter_client/models/domain/user.dart';
import 'package:xzll_im_flutter_client/models/enum/divice_type.dart';
import 'package:xzll_im_flutter_client/models/request/login_request.dart';
import 'package:xzll_im_flutter_client/repository/auth_repository.dart';
import 'package:xzll_im_flutter_client/repository/impl/auth_repository_impl.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/utils/auth_tools.dart';

class LoginController extends GetxController {
  static LoginController get to => Get.find();

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthRepository _repo = AuthRepositoryImpl();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  // 获取全局数据控制器
  AppData get _appData => Get.find<AppData>();

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  /// 表单验证
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// 处理登录
  Future<void> handleLogin() async {
    if (!validateForm()) return;

    try {
      isLoading(true);

      final loginRequest = LoginRequest(
        username: usernameController.text.trim(),
        password: passwordController.text,
        deviceType: DeviceType.android.code,
      );

      final result = await _login(loginRequest);

      if (result.success) {
        _showSuccessMessage('登录成功！欢迎 ${result.data?.userName ?? ''}');
        Get.offAllNamed(RouterName.home);
      } else {
        _showErrorMessage(result.message ?? '登录失败');
      }
    } catch (e) {
      _showErrorMessage('网络异常，请稍后重试');
    } finally {
      isLoading(false);
    }
  }

  /// 用户登录逻辑
  Future<ApiResponse<User>> _login(LoginRequest request) async {
    try {
      final resp = await _repo.login(request);
      if (resp['code'] == 1) {
        final data = resp['data'];
        if (data != null) {
          final accessToken = data['token'];
          final refreshToken = data['refreshToken'];

          // 解析用户（JWT）
          final user = accessToken != null ? AuthTools.parseUserFromToken(accessToken) : null;
          final finalUser = user ?? User(id: '', userName: request.username);

          // 更新全局状态
          _appData.setAuthState(
            user: finalUser,
            accessToken: accessToken,
            refreshToken: refreshToken,
          );

          // ✅ 设置ApiConfig的token，供API调用使用
          if (accessToken != null) {
            ApiConfig.setCurrentUser(finalUser.id, accessToken);
          }

          // 保存到本地
          await _appData.saveAuthState();
          
          // ✅ 登录成功后获取我的完整用户信息（包括头像）
          await _loadMyCompleteUserInfo(finalUser.id);
          
          return ApiResponse.success(finalUser);
        }
        return ApiResponse.error('登录响应数据为空');
      }
      return ApiResponse.error(resp['msg'] ?? '登录失败');
    } catch (e) {
      info('登录异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 获取我的完整用户信息（包括头像），直接调用API
  Future<void> _loadMyCompleteUserInfo(String userId) async {
    try {
      info('🔍 登录时获取我的完整用户信息: $userId');
      
      // ✅ 直接调用个人信息接口获取最新信息
      await _loadMyUserInfoFromAPI(userId);
    } catch (e) {
      error('❌ 获取我的用户信息失败: $e');
    }
  }

  /// 从个人信息接口 /api/user/profile/me 获取我的用户信息
  Future<void> _loadMyUserInfoFromAPI(String userId) async {
    try {
      info('🔍 调用/api/user/profile/me接口获取我的用户信息');
      info('🔍 当前token: ${ApiConfig.token?.substring(0, 20)}...');
      
      // ✅ 调用真正的个人信息接口
      final userInfo = await UserApi.getMyUserInfo();
      
      if (userInfo != null) {
        info('✅ 从/me接口获取到我的用户信息:');
        info('   - userId: ${userInfo.userId}');
        info('   - userName: ${userInfo.userName}');
        info('   - userFullName: ${userInfo.userFullName}');
        info('   - headImage: ${userInfo.headImage}');
        info('   - sex: ${userInfo.sex}');
        
        // 更新当前用户信息，包含头像
        final updatedUser = User(
          id: _appData.user.value.id,
          userName: userInfo.userFullName ?? userInfo.userName,
          avatar: userInfo.headImage, // 设置头像
          phone: userInfo.phone, // 使用从API获取的phone信息
          sex: userInfo.sex,
        );
        
        _appData.updateUser(updatedUser);
        await _appData.saveAuthState();
        
        info('✅ 已从/me接口更新我的用户信息，头像URL: ${updatedUser.avatar}');
        info('✅ 当前AppData中的用户头像: ${_appData.user.value.avatar}');
      } else {
        info('⚠️ /me接口未返回我的用户信息');
      }
    } catch (e) {
      error('❌ 调用/me接口失败: $e');
    }
  }

  /// 跳转到注册页面
  void navigateToRegister() {
    Get.toNamed(RouterName.register);
  }

  /// 跳转到忘记密码页面
  void navigateToForgotPassword() {
    // TODO: 添加忘记密码路由
    Get.snackbar('提示', '忘记密码功能开发中...');
  }

  /// 显示成功消息
  void _showSuccessMessage(String message) {
    Get.snackbar(
      '成功',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    Get.snackbar(
      '错误',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
