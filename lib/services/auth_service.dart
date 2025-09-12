import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  // 单例模式
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // API基础URL - 使用您的实际IP地址
  static const String _baseUrl = 'http://120.46.85.43:80'; // 你的服务器地址
  static const String _authPath = '/im-auth';
  
  // 存储键名
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userInfoKey = 'user_info';
  static const String _deviceTypeKey = 'device_type';
  
  // 当前用户信息
  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  int _deviceType = DeviceType.android.code; // 默认Android

  // Getters
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken != null && _currentUser != null;

  /// 初始化服务，从本地存储恢复用户状态
  Future<bool> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_accessTokenKey);
      _refreshToken = prefs.getString(_refreshTokenKey);
      _deviceType = prefs.getInt(_deviceTypeKey) ?? DeviceType.android.code;
      
      final userInfoString = prefs.getString(_userInfoKey);
      if (userInfoString != null) {
        final userJson = jsonDecode(userInfoString);
        _currentUser = User.fromJson(userJson);
      }

      // 如果有token，验证其有效性
      if (_accessToken != null) {
        final isValid = await validateToken();
        if (!isValid) {
          // Token无效，尝试刷新
          if (_refreshToken != null) {
            final refreshResult = await refreshToken();
            return refreshResult.success;
          } else {
            // 清除无效的登录状态
            await logout();
            return false;
          }
        }
        return true;
      }
      
      return false;
    } catch (e) {
      print('初始化认证服务失败: $e');
      return false;
    }
  }

  /// 用户注册
  Future<ApiResponse<User>> register(RegisterRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl$_authPath/user/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('注册请求: ${request.toJson()}');
      print('注册响应状态: ${response.statusCode}');
      print('注册响应内容: ${response.body}');
      print('注册响应头: ${response.headers}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('注册响应解析: $jsonData');
        
        // 检查注册是否成功 - 服务端成功时code为1，失败时为-200
        if (jsonData['code'] == 1 || jsonData['success'] == true) {
          // 注册成功，解析用户信息
          User user;
          if (jsonData['data'] != null) {
            user = User.fromJson(jsonData['data']);
          } else {
            // 如果没有返回用户信息，创建基础用户对象
            user = User(
              id: '', // 注册后需要登录获取完整信息
              userName: request.userName,
              phone: request.phone,
              sex: request.sex,
            );
          }
          return ApiResponse.success(user);
        } else {
          // 注册失败
          return ApiResponse.error(jsonData['msg'] ?? jsonData['message'] ?? '注册失败');
        }
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(errorData['msg'] ?? errorData['message'] ?? '注册失败，请稍后重试');
      }
    } catch (e) {
      print('注册异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 用户登录
  Future<ApiResponse<User>> login(LoginRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl$_authPath/oauth/token');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: request.toFormData(),
      );

      print('登录请求: ${request.toFormData()}');
      print('登录响应状态: ${response.statusCode}');
      print('登录响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('登录响应解析: $jsonData');
        
        // 检查登录是否成功 - 服务端成功时code为1
        if (jsonData['code'] == 1) {
          final data = jsonData['data'];
          if (data != null) {
            _accessToken = data['token'];
            _refreshToken = data['refreshToken'];
            _deviceType = request.deviceType;

            // 从JWT token中解析用户信息
            _currentUser = _parseUserFromToken(_accessToken!);

            // 保存到本地存储
            await _saveToLocalStorage();

            return ApiResponse.success(_currentUser!);
          } else {
            return ApiResponse.error('登录响应数据为空');
          }
        } else {
          // 登录失败
          return ApiResponse.error(jsonData['msg'] ?? '登录失败');
        }
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(errorData['msg'] ?? errorData['error_description'] ?? '登录失败，请检查用户名和密码');
      }
    } catch (e) {
      print('登录异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 验证Token
  Future<bool> validateToken() async {
    if (_accessToken == null) return false;
    
    try {
      final url = Uri.parse('$_baseUrl$_authPath/oauth/validate?token=$_accessToken');
      final request = TokenValidateRequest(
        token: _accessToken!,
        deviceType: _deviceType,
      );
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Token验证响应状态: ${response.statusCode}');
      print('Token验证响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['success'] == true || jsonData['valid'] == true;
      }
      return false;
    } catch (e) {
      print('Token验证异常: $e');
      return false;
    }
  }

  /// 刷新Token
  Future<ApiResponse<String>> refreshToken() async {
    if (_refreshToken == null) {
      return ApiResponse.error('没有刷新令牌');
    }

    try {
      final url = Uri.parse('$_baseUrl$_authPath/oauth/refresh');
      final request = TokenRefreshRequest(
        refreshToken: _refreshToken!,
        deviceType: _deviceType,
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Token刷新响应状态: ${response.statusCode}');
      print('Token刷新响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        
        if (authResponse.isSuccess) {
          _accessToken = authResponse.accessToken;
          if (authResponse.refreshToken != null) {
            _refreshToken = authResponse.refreshToken;
          }

          // 保存到本地存储
          await _saveToLocalStorage();

          return ApiResponse.success(_accessToken!);
        } else {
          return ApiResponse.error(authResponse.errorDescription ?? 'Token刷新失败');
        }
      } else {
        return ApiResponse.error('Token刷新失败');
      }
    } catch (e) {
      print('Token刷新异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 用户登出
  Future<bool> logout() async {
    try {
      if (_accessToken != null && _currentUser != null) {
        final url = Uri.parse('$_baseUrl$_authPath/oauth/logout');
        final request = LogoutRequest(
          userId: _currentUser!.id,
          deviceType: _deviceType,
        );

        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $_accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(request.toJson()),
        );

        print('登出响应状态: ${response.statusCode}');
        print('登出响应内容: ${response.body}');
      }
    } catch (e) {
      print('登出请求异常: $e');
    }

    // 清除本地状态
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    
    // 清除本地存储
    await _clearLocalStorage();
    
    return true;
  }

  /// 获取授权头
  Map<String, String> getAuthHeaders() {
    if (_accessToken != null) {
      return {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  /// 保存到本地存储
  Future<void> _saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_accessToken != null) {
      await prefs.setString(_accessTokenKey, _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString(_refreshTokenKey, _refreshToken!);
    }
    if (_currentUser != null) {
      await prefs.setString(_userInfoKey, jsonEncode(_currentUser!.toJson()));
    }
    await prefs.setInt(_deviceTypeKey, _deviceType);
  }

  /// 清除本地存储
  Future<void> _clearLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userInfoKey);
    await prefs.remove(_deviceTypeKey);
  }

  /// 从JWT Token中解析用户信息
  User? _parseUserFromToken(String token) {
    try {
      // JWT Token格式: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // 解码payload部分
      final payload = parts[1];
      // 添加padding以确保base64解码正确
      final normalizedPayload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));
      final payloadJson = jsonDecode(decoded);

      print('JWT Payload: $payloadJson');

      return User(
        id: payloadJson['id']?.toString() ?? '',
        userName: payloadJson['user_name'] ?? '',
        // JWT中可能不包含phone和sex信息
      );
    } catch (e) {
      print('解析JWT Token异常: $e');
      return null;
    }
  }

  /// 设置API基础URL（用于开发/生产环境切换）
  void setBaseUrl(String baseUrl) {
    // 这里可以实现动态设置API地址的逻辑
    print('设置API基础URL: $baseUrl');
  }
}
