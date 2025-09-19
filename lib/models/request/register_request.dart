// 注册请求模型
class RegisterRequest {
  final String userName;
  final String password;
  final String phone;
  final int sex; // 1-男, 2-女
  final int registerTerminalType; // 注册终端类型

  RegisterRequest({
    required this.userName,
    required this.password,
    required this.phone,
    required this.sex,
    required this.registerTerminalType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
      'phone': phone,
      'sex': sex,
      'registerTerminalType': registerTerminalType,
    };
  }
}
