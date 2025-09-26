import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/repository/auth_repository.dart';
import 'package:xzll_im_flutter_client/repository/impl/auth_repository_impl.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/services/connectivity_services.dart';
import 'package:xzll_im_flutter_client/services/data_base_service.dart';
import 'package:xzll_im_flutter_client/services/websocket_service.dart';
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
    Get.put(AppData());
    Get.put(ConnectivityServices());
    Get.lazyPut(() => DataBaseService());
    Get.lazyPut(() => WebSocketService());
  }

  Future<void> initRepository() async {
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl());
  }

  ///校验认证状态
  Future<void> validateAuth() async {
    final AuthRepository repo = Get.find<AuthRepository>();
    final cacheAuthData = await AuthTools.loadAuthState();
    if (cacheAuthData.accessToken != null && cacheAuthData.refreshToken != null) {
      var validateToken = await repo.validateToken(cacheAuthData.accessToken!);
      if (validateToken.success) {
        var refreshResponse = await repo.refreshToken(cacheAuthData.refreshToken!);
        if (refreshResponse.success) {
          _appData.setAuthState(
            accessToken: refreshResponse.data?.token,
            refreshToken: refreshResponse.data?.refreshToken,
            user: AuthTools.parseUserFromToken(refreshResponse.data?.token ?? ""),
          );
          Get.offAllNamed(RouterName.home);
        } else {
          error("refreshResponse，login");
          Get.offAllNamed(RouterName.login);
        }
      } else {
        error("校验token失败，login");
        Get.offAllNamed(RouterName.login);
      }
    } else {
      error('没有认证缓存，跳转到登录界面');
      // await AuthTools.clearAuthState();
      Get.offAllNamed(RouterName.login);
    }
  }
}
