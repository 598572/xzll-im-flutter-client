// Token验证请求模型
class TokenValidateRequest {
  final String token;
  final int deviceType;

  TokenValidateRequest({required this.token, required this.deviceType});

  Map<String, dynamic> toJson() {
    return {'token': token, 'deviceType': deviceType};
  }
}
