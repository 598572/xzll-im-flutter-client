import '../constant/app_config.dart';

/// API配置
class ApiConfig {
  // 服务器地址 - 使用统一的配置源
  static String get baseUrl => '${AppConfig.baseUrl}/im-business';
  
  // 当前用户信息
  static String? token;
  static String? currentUserId;
  
  /// 设置当前用户信息
  static void setCurrentUser(String userId, String userToken) {
    currentUserId = userId;
    token = userToken;
  }
}
