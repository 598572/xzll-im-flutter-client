import 'package:xzll_im_flutter_client/models/request_model.dart';

abstract class AuthRepository {
  /// 用户注册
  Future<Map<String, dynamic>> register(RegisterRequest request);

  /// 用户登录
  Future<Map<String, dynamic>> login(LoginRequest request);

  /// 验证 Token
  Future<Map<String, dynamic>> validateToken(String accessToken, int deviceType);

  /// 刷新 Token
  Future<Map<String, dynamic>> refreshToken(String refreshToken, int deviceType);

  /// 用户登出
  Future<Map<String, dynamic>> logout(String accessToken, String userId, int deviceType);
}


