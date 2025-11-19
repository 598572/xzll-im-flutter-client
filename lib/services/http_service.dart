import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/repository/auth_repository.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/utils/auth_tools.dart';

/// 通用HTTP服务，支持token自动刷新
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  AppData get _appData => Get.find<AppData>();
  
  /// 发送POST请求，支持token自动刷新
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool enableTokenRefresh = true,
  }) async {
    // 合并授权头
    final requestHeaders = <String, String>{};
    requestHeaders.addAll(_appData.getAuthHeaders());
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    info('📤 HTTP POST: $url');
    
    // 发送请求
    final response = await http.post(url, headers: requestHeaders, body: body);
    
    info('📥 HTTP响应: ${response.statusCode}');
    
    // 检查是否需要token刷新
    if (enableTokenRefresh && response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        if (jsonData['code'] == -200) {
          info('🔄 检测到token过期，尝试自动刷新...');
          
          bool refreshed = await _attemptTokenRefresh();
          if (refreshed) {
            info('✅ token刷新成功，重试原请求');
            // 重新生成授权头
            final newHeaders = <String, String>{};
            newHeaders.addAll(_appData.getAuthHeaders());
            if (headers != null) {
              newHeaders.addAll(headers);
            }
            
            // 重试原请求
            return await http.post(url, headers: newHeaders, body: body);
          } else {
            error('❌ token刷新失败，跳转到登录页面');
            await _appData.clearLocalAuthState();
            Get.offAllNamed(RouterName.login);
          }
        }
      } catch (e) {
        info('⚠️ 解析响应JSON失败: $e');
      }
    }
    
    return response;
  }
  
  /// 尝试刷新token
  Future<bool> _attemptTokenRefresh() async {
    try {
      if (_appData.refreshToken.value.isEmpty) {
        error('❌ 没有refreshToken，无法刷新');
        return false;
      }
      
      final AuthRepository repo = Get.find<AuthRepository>();
      final refreshResponse = await repo.refreshToken(_appData.refreshToken.value);
      
      if (refreshResponse.success) {
        info('✅ token刷新成功');
        _appData.setAuthState(
          accessToken: refreshResponse.data?.token,
          refreshToken: refreshResponse.data?.refreshToken,
          user: AuthTools.parseUserFromToken(refreshResponse.data?.token ?? ""),
        );
        await _appData.saveAuthState();
        return true;
      } else {
        error('❌ refreshToken已过期: ${refreshResponse.message}');
        return false;
      }
    } catch (e) {
      error('❌ token刷新异常: $e');
      return false;
    }
  }
  
  /// 发送GET请求，支持token自动刷新
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool enableTokenRefresh = true,
  }) async {
    // 合并授权头
    final requestHeaders = <String, String>{};
    requestHeaders.addAll(_appData.getAuthHeaders());
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    info('📤 HTTP GET: $url');
    
    // 发送请求
    final response = await http.get(url, headers: requestHeaders);
    
    info('📥 HTTP响应: ${response.statusCode}');
    
    // 检查是否需要token刷新
    if (enableTokenRefresh && response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        if (jsonData['code'] == -200) {
          info('🔄 检测到token过期，尝试自动刷新...');
          
          bool refreshed = await _attemptTokenRefresh();
          if (refreshed) {
            info('✅ token刷新成功，重试原请求');
            // 重新生成授权头
            final newHeaders = <String, String>{};
            newHeaders.addAll(_appData.getAuthHeaders());
            if (headers != null) {
              newHeaders.addAll(headers);
            }
            
            // 重试原请求
            return await http.get(url, headers: newHeaders);
          } else {
            error('❌ token刷新失败，跳转到登录页面');
            await _appData.clearLocalAuthState();
            Get.offAllNamed(RouterName.login);
          }
        }
      } catch (e) {
        info('⚠️ 解析响应JSON失败: $e');
      }
    }
    
    return response;
  }
}
