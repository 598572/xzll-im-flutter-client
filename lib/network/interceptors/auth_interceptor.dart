import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:xzll_im_flutter_client/constant/app_data.dart';

///2025/9/26
///kurban
class AuthInterceptor extends Interceptor {
  final AppData appData = Get.find<AppData>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (appData.token.value.isNotEmpty) {
      options.headers['Authorization'] = "Bearer ${appData.token.value}";
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
