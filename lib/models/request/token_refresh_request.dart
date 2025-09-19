// Token刷新请求模型
class TokenRefreshRequest {
  final String refreshToken;
  final int deviceType;

  TokenRefreshRequest({required this.refreshToken, required this.deviceType});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken, 'deviceType': deviceType};
  }
}
