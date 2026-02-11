import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';

///2025/9/26
///kurban
class AuthInterceptor extends Interceptor {
  // ✅ 延迟获取 AppData，避免在 Web 端初始化时 AppData 还未注册
  // Web 端的初始化顺序与 App 端不同，可能在 SplashPage 之前就创建 DioClient
  AppData get appData => Get.find<AppData>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (appData.token.value.isNotEmpty) {
      options.headers['Authorization'] = "Bearer ${appData.token.value}";
    }
    
    // ✅ 调试：打印实际发送的请求头（仅对登录请求）
    if (options.path.contains('/oauth/token')) {
      info('🔍 [登录请求调试] 实际发送的请求头:');
      options.headers.forEach((key, value) {
        info('   $key: $value');
      });
      info('🔍 [登录请求调试] 请求URL: ${options.uri}');
      info('🔍 [登录请求调试] 请求方法: ${options.method}');
      if (options.data != null) {
        info('🔍 [登录请求调试] 请求数据: ${options.data}');
        info('🔍 [登录请求调试] 数据类型: ${options.data.runtimeType}');
      }
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }
}
