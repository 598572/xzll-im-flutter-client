import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/api_response.dart';
import 'package:xzll_im_flutter_client/models/domain/user.dart';
import 'package:xzll_im_flutter_client/models/enum/divice_type.dart';
import 'package:xzll_im_flutter_client/models/request/register_request.dart';
import 'package:xzll_im_flutter_client/repository/auth_repository.dart';
import 'package:xzll_im_flutter_client/repository/impl/auth_repository_impl.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';

class RegisterController extends GetxController {
  static RegisterController get to => Get.find();

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final AuthRepository _repo = AuthRepositoryImpl();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxInt selectedSex = 1.obs; // 1-男, 2-女

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  /// 切换确认密码可见性
  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  /// 设置性别
  void setSex(int sex) {
    selectedSex(sex);
  }

  /// 表单验证
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// 验证手机号
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'plz_enter_phone'.tr;
    }

    final phoneRegex = RegExp(r'^1[3-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'plz_enter_valid_phone'.tr;
    }

    return null;
  }

  /// 验证确认密码
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'plz_reenter_password'.tr;
    }
    if (value != passwordController.text) {
      return 'password_mismatch'.tr;
    }
    return null;
  }

  /// 处理注册
  Future<void> handleRegister() async {
    if (!validateForm()) return;

    try {
      isLoading(true);

      final registerRequest = RegisterRequest(
        userName: usernameController.text.trim(),
        password: passwordController.text,
        phone: phoneController.text.trim(),
        sex: selectedSex.value,
        registerTerminalType: DeviceType.android.code,
      );

      final result = await _register(registerRequest);

      if (result.success) {
        _showSuccessMessage('register_success'.tr);
        Get.offNamed(RouterName.login);
      } else {
        _showErrorMessage(result.message ?? 'register_failed'.tr);
      }
    } catch (e) {
      _showErrorMessage('network_exception_retry'.tr);
    } finally {
      isLoading(false);
    }
  }

  /// 用户注册逻辑
  Future<ApiResponse<User>> _register(RegisterRequest request) async {
    try {
      final resp = await _repo.register(request);
      if ((resp['code'] == 1) || resp['success'] == true) {
        // 服务器可能返回 data 中的用户信息，也可能没有
        User user;
        if (resp['data'] != null) {
          user = User.fromJson(resp['data']);
        } else {
          user = User(id: '', userName: request.userName, phone: request.phone, sex: request.sex);
        }
        return ApiResponse.success(user);
      }
      return ApiResponse.error(resp['msg'] ?? resp['message'] ?? 'register_failed'.tr);
    } catch (e) {
      info('register_exception'.trParams({'error': e.toString()}));
      return ApiResponse.error('network_exception_check_internet'.tr);
    }
  }

  /// 返回登录页面
  void navigateBack() {
    Get.back();
  }

  /// 显示成功消息
  void _showSuccessMessage(String message) {
    Get.snackbar(
      'success'.tr,
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
      'error'.tr,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}
