import 'package:xzll_im_flutter_client/models/domain/api_response.dart';
import 'package:xzll_im_flutter_client/models/domain/auth_response.dart';
import 'package:xzll_im_flutter_client/models/request_model.dart';

abstract class AuthRepository {
  /// 用户注册
  Future<Map<String, dynamic>> register(RegisterRequest request);

  /// 用户登录
  Future<Map<String, dynamic>> login(LoginRequest request);

  /// 验证 Token
  Future<ApiResponse> validateToken(String accessToken);

  /// 刷新 Token
  Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken);

  /// 用户登出
  Future<Map<String, dynamic>> logout(String accessToken, String userId);
}
