/// API配置
class ApiConfig {
  // 服务器地址
  static const String baseUrl = 'http://120.46.85.43:80/im-business';
  
  // 当前用户信息
  static String? token;
  static String? currentUserId;
  
  /// 设置当前用户信息
  static void setCurrentUser(String userId, String userToken) {
    currentUserId = userId;
    token = userToken;
  }
}
