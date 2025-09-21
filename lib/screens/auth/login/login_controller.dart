import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            deviceType: request.deviceType,
          );

          // 保存到本地
          await _appData.saveAuthState();
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

  /// 跳转到注册页面
  void navigateToRegister() {
    Get.toNamed(RouterName.register);
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
