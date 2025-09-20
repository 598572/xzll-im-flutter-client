import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/services/auth_service.dart';
import 'package:xzll_im_flutter_client/services/connectivity_services.dart';
import 'package:xzll_im_flutter_client/services/websocket_service.dart';
import 'package:xzll_im_flutter_client/utils/auth_tools.dart';

class SplashLogic extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
    initServices();
  }

  Future<void> _checkAuthStatus() async {
    final authService = AuthService();
    try {
      // 1. 读取本地缓存
      final cached = await AuthTools.loadAuthState();
      authService.setAuthState(
        user: cached.user,
        accessToken: cached.accessToken,
        refreshToken: cached.refreshToken,
        deviceType: cached.deviceType,
      );

      // 2. 没有 token -> 登录页
      if (cached.accessToken == null) {
        info('启动: 未发现本地 token, 跳转登录页');
        Get.offAllNamed(RouterName.login);
        return;
      }

      // 3. 验证 token
      final valid = await authService.validateToken();
      if (valid) {
        info('启动: 本地 token 有效, 进入首页');
        Get.offAllNamed(RouterName.home);
        return;
      }

      // 4. token 无效，尝试刷新
      if (cached.refreshToken != null) {
        info('启动: token 失效，尝试刷新');
        final refreshResult = await authService.refreshToken();
        if (refreshResult.success) {
          info('启动: 刷新成功，进入首页');
          Get.offAllNamed(RouterName.home);
          return;
        }
        info('启动: 刷新失败，清理缓存并跳转登录');
        await AuthTools.clearAuthState();
        Get.offAllNamed(RouterName.login);
        return;
      }

      // 5. 没有 refreshToken
      info('启动: 无刷新令牌，跳转登录');
      await AuthTools.clearAuthState();
      Get.offAllNamed(RouterName.login);
    } catch (e) {
      info('启动: 初始化异常 $e');
      await AuthTools.clearAuthState();
      Get.offAllNamed(RouterName.login);
    }
  }

  void initServices() {
    Get.put(ConnectivityServices());
    Get.lazyPut(() => WebSocketService());
  }
}
