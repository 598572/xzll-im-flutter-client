import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/api_response.dart';
import 'package:xzll_im_flutter_client/models/domain/auth_response.dart';
import 'package:xzll_im_flutter_client/models/enum/divice_type.dart';
import 'package:xzll_im_flutter_client/repository/auth_repository.dart';
import 'package:xzll_im_flutter_client/repository/impl/auth_repository_impl.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/services/connectivity_services.dart';
import 'package:xzll_im_flutter_client/services/data_base_service.dart';
import 'package:xzll_im_flutter_client/services/websocket_service.dart';
import 'package:xzll_im_flutter_client/utils/auth_tools.dart';

class SplashLogic extends GetxController {
  final AuthRepository _repo = AuthRepositoryImpl();

  // 获取全局数据控制器
  AppData get _appData => Get.find<AppData>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
    initServices();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // 1. 读取本地缓存
      final cached = await AuthTools.loadAuthState();

      _appData.setAuthState(
        user: cached.user,
        refreshToken: cached.refreshToken,
        accessToken: cached.accessToken,
      );

      // 5. 验证 token 有效性（网络检查）
      final valid = await _validateToken();
      if (valid) {
        info('启动: Token验证通过，进入首页');
        await _navigateToHome();
        return;
      }

      info('启动: Token失效，尝试刷新');
      final refreshResult = await _refreshToken();
      if (refreshResult.success) {
        info('启动: Token刷新成功，进入首页');
        await _navigateToHome();
        return;
      } else {
        // 7. 刷新失败或无RefreshToken，清理并跳转登录
        info('启动: Token刷新失败或无RefreshToken，清理缓存并跳转登录');
        await _clearAndNavigateToLogin();
      }
    } catch (e) {
      info('启动: 鉴权过程异常 - $e');
      await _clearAndNavigateToLogin();
    }
  }

  /// 验证当前 accessToken 是否有效
  Future<bool> _validateToken() async {
    final token = _appData.token.value;
    if (token.isEmpty) return false;
    try {
      final resp = await _repo.validateToken(token, _appData.deviceType.value);
      // 后端有可能返回 success 或 valid 字段
      return resp['success'] == true;
    } catch (e) {
      info('Token验证异常: $e');
      return false;
    }
  }

  /// 刷新 Token
  Future<ApiResponse<String>> _refreshToken() async {
    final refreshToken = _appData.refreshToken.value;
    if (refreshToken.isEmpty) {
      return ApiResponse.error('没有刷新令牌');
    }
    try {
      final resp = await _repo.refreshToken(refreshToken, _appData.deviceType.value);
      if (resp['code'] == 1) {
        // 兼容之前 AuthResponse 结构
        final authResp = AuthResponse.fromJson(resp["data"]);
        if (authResp.isSuccess) {
          final newAccessToken = authResp.accessToken;
          final newRefreshToken = authResp.refreshToken;

          // 解析用户（若之前未解析）
          if (_appData.user.value.id.isEmpty && newAccessToken != null) {
            final user = AuthTools.parseUserFromToken(newAccessToken);
            if (user != null) {
              _appData.setAuthState(
                user: user,
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
                deviceType: DeviceType.currentDeviceType.code,
              );
              _navigateToHome();
            } else {
              _clearAndNavigateToLogin();
            }
          }

          // 保存到本地
          await _appData.saveAuthState();
          return ApiResponse.success(_appData.token.value);
        }
        return ApiResponse.error(authResp.errorDescription ?? 'Token刷新失败');
      }
      return ApiResponse.error(resp['msg'] ?? 'Token刷新失败');
    } catch (e) {
      info('Token刷新异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 清理缓存并跳转登录页
  Future<void> _clearAndNavigateToLogin() async {
    await _appData.clearLocalAuthState();
    Get.offAllNamed(RouterName.login);
  }

  /// 跳转到首页
  Future<void> _navigateToHome() async {
    Get.offAllNamed(RouterName.home);
  }

  void initServices() {
    Get.put(AppData());
    Get.put(ConnectivityServices());
    Get.lazyPut(() => DataBaseService());
    Get.lazyPut(() => WebSocketService());
  }
}
