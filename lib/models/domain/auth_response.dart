import 'package:json_annotation/json_annotation.dart';
import 'package:xzll_im_flutter_client/models/domain/user.dart';

part 'auth_response.g.dart';

// 认证响应模型
@JsonSerializable()
class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  final String? scope;
  final User? user;
  final String? error;
  final String? errorDescription;

  AuthResponse({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
    this.scope,
    this.user,
    this.error,
    this.errorDescription,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  bool get isSuccess => accessToken != null && error == null;
}
