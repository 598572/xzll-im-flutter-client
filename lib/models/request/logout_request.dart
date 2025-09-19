// 登出请求模型
class LogoutRequest {
  final String userId;
  final int deviceType;

  LogoutRequest({required this.userId, required this.deviceType});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'deviceType': deviceType};
  }
}
