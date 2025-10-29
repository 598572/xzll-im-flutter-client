import 'package:dio/dio.dart';
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
    var response = await DioClient.post(
      "$_authPath/oauth/token",
      options: Options(headers: {'Content-Type': 'application/x-www-form-urlencoded'}),
      data: request.toJson(),
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
