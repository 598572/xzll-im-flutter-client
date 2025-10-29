// 登录请求模型
class LoginRequest {
  final String username;
  final String password;
  final int deviceType; // 设备类型: 1-Android, 2-iOS, 3-Web, 4-Desktop

  LoginRequest({required this.username, required this.password, required this.deviceType});

  Map<String, String> toJson() {
    return {
      'grant_type': 'password',
      'client_id': 'client-app',
      'client_secret': '123456',
      'username': username,
      'password': password,
      'device_type': deviceType.toString(),
    };
  }
}
