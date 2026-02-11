import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:xzll_im_flutter_client/constant/app_config.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/api_response.dart';
import 'package:xzll_im_flutter_client/models/domain/auth_response.dart';
import 'package:xzll_im_flutter_client/models/enum/divice_type.dart';
import 'package:xzll_im_flutter_client/models/request/login_request.dart';
import 'package:xzll_im_flutter_client/models/request/logout_request.dart';
import 'package:xzll_im_flutter_client/models/request/register_request.dart';
import 'package:xzll_im_flutter_client/models/request/token_refresh_request.dart';
import 'package:xzll_im_flutter_client/models/request/token_validate_request.dart';
import 'package:xzll_im_flutter_client/network/dio_client.dart';
import 'package:xzll_im_flutter_client/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _authPath = '/im-auth';

  @override
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    var response = await DioClient.post("$_authPath/user/register", data: request.toJson());
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    // ✅ 使用配置的server地址
    final url = Uri.parse('${AppConfig.baseUrl}$_authPath/oauth/token');
    
    // ✅ 手动将Map转换为URL编码的字符串（匹配Apifox的--data-urlencode）
    final formDataMap = request.toJson();
    final formDataString = formDataMap.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    // ✅ 请求头
    final headers = {
      'Accept': '*/*',
      'Host': url.host, // 动态使用URL的host
      'Connection': 'keep-alive',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    
    info('🔍 [登录请求] 使用http包发送请求（匹配Apifox格式）');
    info('🔍 [登录请求] URL: $url');
    info('🔍 [登录请求] 请求头:');
    headers.forEach((key, value) {
      info('   $key: $value');
    });
    info('🔍 [登录请求] 请求体: $formDataString');
    
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: formDataString,
      );
      
      info('🔍 [登录响应] 状态码: ${response.statusCode}');
      info('🔍 [登录响应] 响应头: ${response.headers}');
      if (response.statusCode == 200) {
        info('🔍 [登录响应] 响应体: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      } else {
        info('🔍 [登录响应] 响应体: ${response.body}');
      }
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // 如果http包也失败，尝试使用Dio作为备用
        info('⚠️ http包请求失败，尝试使用Dio作为备用...');
        return await _loginWithDio(request);
      }
    } catch (e) {
      error('❌ http包请求异常: $e');
      // 如果http包失败，尝试使用Dio作为备用
      info('⚠️ http包请求异常，尝试使用Dio作为备用...');
      return await _loginWithDio(request);
    }
  }
  
  /// 使用Dio发送登录请求（备用方案）
  Future<Map<String, dynamic>> _loginWithDio(LoginRequest request) async {
    final baseUrl = AppConfig.baseUrl;
    final formDataMap = request.toJson();
    final formDataString = formDataMap.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
    
    var response = await DioClient.post(
      "$_authPath/oauth/token",
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'Origin': baseUrl,
          'Referer': '$baseUrl/',
          'X-Requested-With': 'XMLHttpRequest',
        },
        method: 'POST',
      ),
      data: formDataString,
    );
    return response.data;
  }

  @override
  Future<ApiResponse> validateToken(String accessToken) async {
    var response = await DioClient.post(
      "$_authPath/oauth/validate",
      queryParameters: {"token": accessToken},
      data: TokenValidateRequest(
        deviceType: DeviceType.currentDeviceType.code,
        token: accessToken,
      ).toJson(),
    );
    return ApiResponse.fromJson(response.data);
  }

  @override
  Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken) async {
    final req = TokenRefreshRequest(
      refreshToken: refreshToken,
      deviceType: DeviceType.currentDeviceType.code,
    );
    var response = await DioClient.post("$_authPath/oauth/refresh", data: req.toJson());
    return ApiResponse.fromJson(response.data, fromJsonT: AuthResponse.fromJson);
  }

  @override
  Future<Map<String, dynamic>> logout(String accessToken, String userId) async {
    final req = LogoutRequest(userId: userId, deviceType: DeviceType.currentDeviceType.code);
    var response = await DioClient.post("$_authPath/oauth/refresh", data: req.toJson());
    return response.data;
  }
}
