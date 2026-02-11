import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/repository/auth_repository.dart';
import 'package:xzll_im_flutter_client/repository/impl/auth_repository_impl.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/services/connectivity_services.dart';
import 'package:xzll_im_flutter_client/services/data_base_service.dart';
import 'package:xzll_im_flutter_client/services/imsdk_manager.dart';
import 'package:xzll_im_flutter_client/utils/auth_tools.dart';

class SplashLogic extends GetxController {
  // 获取全局数据控制器
  AppData get _appData => Get.find<AppData>();

  @override
  void onReady() async {
    super.onReady();
    await initServices();
    await initRepository();
    await validateAuth();
  }

  /// 初始化服务
  Future<void> initServices() async {
    await Get.putAsync(() async => await SharedPreferences.getInstance());

    // AppData 和 IMSDKManager 已在 main.dart 中注册，这里不再重复注册
    // 只注册其他服务
    Get.put(ConnectivityServices());
    // ✅ 注册DataBaseService用于用户信息存储（与SDK的消息数据库分离）
    // SDK处理IM消息存储，DataBaseService处理用户个人信息存储
    Get.lazyPut(() => DataBaseService());
  }

  Future<void> initRepository() async {
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl());
  }

  ///校验认证状态
  Future<void> validateAuth() async {
    final AuthRepository repo = Get.find<AuthRepository>();
    final cacheAuthData = await AuthTools.loadAuthState();
    if (cacheAuthData.accessToken != null && cacheAuthData.refreshToken != null) {
      info('📋 检查本地缓存的认证信息');

      var validateToken = await repo.validateToken(cacheAuthData.accessToken!);
      if (validateToken.success) {
        info('✅ token仍然有效，直接使用并刷新');
        // token仍然有效，使用当前token并尝试刷新获取新的
        _appData.setAuthState(
          accessToken: cacheAuthData.accessToken,
          refreshToken: cacheAuthData.refreshToken,
          user: AuthTools.parseUserFromToken(cacheAuthData.accessToken ?? ""),
        );

        // 连接IM服务器
        await _connectIMServer();

        // 可选：异步刷新token获取新的，但不影响当前登录状态
        _tryRefreshTokenInBackground(repo, cacheAuthData.refreshToken!);
        Get.offAllNamed(RouterName.home);
      } else {
        info('⚠️ token已过期，尝试使用refreshToken自动刷新');
        // token过期，使用refreshToken刷新
        var refreshResponse = await repo.refreshToken(cacheAuthData.refreshToken!);
        if (refreshResponse.success) {
          info('✅ token刷新成功，自动登录');
          _appData.setAuthState(
            accessToken: refreshResponse.data?.token,
            refreshToken: refreshResponse.data?.refreshToken,
            user: AuthTools.parseUserFromToken(refreshResponse.data?.token ?? ""),
          );

          // 连接IM服务器
          await _connectIMServer();

          Get.offAllNamed(RouterName.home);
        } else {
          error("❌ refreshToken也已过期，需要重新登录");
          await AuthTools.clearAuthState();
          Get.offAllNamed(RouterName.login);
        }
      }
    } else {
      error('❌ 没有认证缓存，跳转到登录界面');
      await AuthTools.clearAuthState();
      Get.offAllNamed(RouterName.login);
    }
  }

  /// 连接IM服务器
  Future<void> _connectIMServer() async {
    try {
      if (IMSDKManager.to.isInitialized) {
        info('🔗 正在连接IM服务器...');
        await IMSDKManager.to.connect();
      } else {
        waring('⚠️ IMSDKManager未初始化，跳过IM连接');
      }
    } catch (e) {
      error('❌ IM服务器连接失败: $e');
    }
  }
  
  /// 后台异步刷新token（不影响当前登录状态）
  Future<void> _tryRefreshTokenInBackground(AuthRepository repo, String refreshToken) async {
    try {
      var refreshResponse = await repo.refreshToken(refreshToken);
      if (refreshResponse.success) {
        info('🔄 后台刷新token成功，更新缓存');
        _appData.setAuthState(
          accessToken: refreshResponse.data?.token,
          refreshToken: refreshResponse.data?.refreshToken,
          user: AuthTools.parseUserFromToken(refreshResponse.data?.token ?? ""),
        );
      } else {
        info('⚠️ 后台刷新token失败，但不影响当前登录状态');
      }
    } catch (e) {
      info('⚠️ 后台刷新token异常: $e');
    }
  }
}
