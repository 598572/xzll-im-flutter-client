import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xzll_im_flutter_client/constant/app_config.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/request/register_request.dart';
import 'package:xzll_im_flutter_client/models/request/login_request.dart';
import 'package:xzll_im_flutter_client/models/request/token_validate_request.dart';
import 'package:xzll_im_flutter_client/models/request/token_refresh_request.dart';
import 'package:xzll_im_flutter_client/models/request/logout_request.dart';
import 'package:xzll_im_flutter_client/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  static const String _authPath = '/im-auth';

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${AppConfig.baseUrl}$_authPath$path');
    if (query == null || query.isEmpty) return uri; // Keep simple for now
    return uri.replace(queryParameters: query.map((k, v) => MapEntry(k, v.toString())));
  }

  Map<String, String> _jsonHeaders() => {'Content-Type': 'application/json'};
  Map<String, String> _formHeaders() => {'Content-Type': 'application/x-www-form-urlencoded'};

  @override
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final url = _uri('/user/register');
      final resp = await http.post(
        url,
        headers: _jsonHeaders(),
        body: jsonEncode(request.toJson()),
      );
      info('注册请求: ${request.toJson()}');
      info('注册响应状态: ${resp.statusCode}');
      info('注册响应内容: ${resp.body}');
      final data = jsonDecode(resp.body);
      data['httpStatus'] = resp.statusCode;
      return data is Map<String, dynamic> ? data : {'success': false, 'msg': '响应格式错误'};
    } catch (e) {
      info('注册异常: $e');
      return {'success': false, 'msg': '网络异常'};
    }
  }

  @override
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final url = _uri('/oauth/token');
      final resp = await http.post(url, headers: _formHeaders(), body: request.toFormData());
      info('登录请求: ${request.toFormData()}');
      info('登录响应状态: ${resp.statusCode}');
      info('登录响应内容: ${resp.body}');
      final data = jsonDecode(resp.body);
      data['httpStatus'] = resp.statusCode;
      return data is Map<String, dynamic> ? data : {'success': false, 'msg': '响应格式错误'};
    } catch (e) {
      info('登录异常: $e');
      return {'success': false, 'msg': '网络异常'};
    }
  }

  @override
  Future<Map<String, dynamic>> validateToken(String accessToken, int deviceType) async {
    try {
      final url = _uri('/oauth/validate', {'token': accessToken});
      final req = TokenValidateRequest(token: accessToken, deviceType: deviceType);
      final resp = await http.post(url, headers: _jsonHeaders(), body: jsonEncode(req.toJson()));
      info('Token验证响应状态: ${resp.statusCode}');
      info('Token验证响应内容: ${resp.body}');
      final data = jsonDecode(resp.body);
      data['httpStatus'] = resp.statusCode;
      return data is Map<String, dynamic> ? data : {'success': false, 'valid': false};
    } catch (e) {
      info('Token验证异常: $e');
      return {'success': false, 'valid': false};
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken, int deviceType) async {
    try {
      final url = _uri('/oauth/refresh');
      final req = TokenRefreshRequest(refreshToken: refreshToken, deviceType: deviceType);
      final resp = await http.post(url, headers: _jsonHeaders(), body: jsonEncode(req.toJson()));
      info('Token刷新响应状态: ${resp.statusCode}');
      info('Token刷新响应内容: ${resp.body}');
      final data = jsonDecode(resp.body);
      data['httpStatus'] = resp.statusCode;
      return data is Map<String, dynamic> ? data : {'success': false, 'msg': '响应格式错误'};
    } catch (e) {
      info('Token刷新异常: $e');
      return {'success': false, 'msg': '网络异常'};
    }
  }

  @override
  Future<Map<String, dynamic>> logout(String accessToken, String userId, int deviceType) async {
    try {
      final url = _uri('/oauth/logout');
      final req = LogoutRequest(userId: userId, deviceType: deviceType);
      final resp = await http.post(
        url,
        headers: {'Authorization': 'Bearer $accessToken', ..._jsonHeaders()},
        body: jsonEncode(req.toJson()),
      );
      info('登出响应状态: ${resp.statusCode}');
      info('登出响应内容: ${resp.body}');
      if (resp.body.isEmpty) return {'success': true, 'httpStatus': resp.statusCode};
      final data = jsonDecode(resp.body);
      data['httpStatus'] = resp.statusCode;
      return data is Map<String, dynamic> ? data : {'success': true};
    } catch (e) {
      info('登出请求异常: $e');
      return {'success': false, 'msg': '网络异常'};
    }
  }
}
