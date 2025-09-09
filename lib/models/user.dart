// 用户模型和认证相关数据模型

// 用户信息模型
class User {
  final String id;
  final String userName;
  final String? phone;
  final int? sex; // 1-男, 2-女
  final String? avatar;
  final DateTime? createTime;

  User({
    required this.id,
    required this.userName,
    this.phone,
    this.sex,
    this.avatar,
    this.createTime,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      userName: json['userName'] ?? '',
      phone: json['phone'],
      sex: json['sex'],
      avatar: json['avatar'],
      createTime: json['createTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['createTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'phone': phone,
      'sex': sex,
      'avatar': avatar,
      'createTime': createTime?.millisecondsSinceEpoch,
    };
  }
}

// 登录请求模型
class LoginRequest {
  final String username;
  final String password;
  final int deviceType; // 设备类型: 1-Android, 2-iOS, 3-Web, 4-Desktop

  LoginRequest({
    required this.username,
    required this.password,
    required this.deviceType,
  });

  Map<String, String> toFormData() {
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

// Token验证请求模型
class TokenValidateRequest {
  final String token;
  final int deviceType;

  TokenValidateRequest({
    required this.token,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'deviceType': deviceType,
    };
  }
}

// Token刷新请求模型
class TokenRefreshRequest {
  final String refreshToken;
  final int deviceType;

  TokenRefreshRequest({
    required this.refreshToken,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
      'deviceType': deviceType,
    };
  }
}

// 登出请求模型
class LogoutRequest {
  final String userId;
  final int deviceType;

  LogoutRequest({
    required this.userId,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deviceType': deviceType,
    };
  }
}

// 认证响应模型
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

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      expiresIn: json['expires_in'],
      scope: json['scope'],
      error: json['error'],
      errorDescription: json['error_description'],
    );
  }

  bool get isSuccess => accessToken != null && error == null;
}

// API响应基础模型
class ApiResponse<T> {
  final bool success;
  final int? code;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    this.code,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      code: json['code'],
      message: json['message'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : null,
    );
  }

  factory ApiResponse.success(T data) {
    return ApiResponse<T>(
      success: true,
      data: data,
    );
  }

  factory ApiResponse.error(String message, {int? code}) {
    return ApiResponse<T>(
      success: false,
      code: code,
      message: message,
    );
  }
}

// 设备类型枚举
enum DeviceType {
  android(1, "Android"),
  ios(2, "iOS"), 
  web(3, "Web"),
  desktop(4, "Desktop");

  const DeviceType(this.code, this.name);
  
  final int code;
  final String name;
}
