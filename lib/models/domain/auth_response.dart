import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

// 认证响应模型
@JsonSerializable()
class AuthResponse {
  final String token;
  final String refreshToken;
  final String tokenHead;
  @JsonKey(defaultValue: 0)
  final int expiresIn;

  AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.tokenHead,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}
