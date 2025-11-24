/// API常量类
class ApiConstants {
  // 服务器基础地址
  static const String baseUrl = 'http://120.46.85.43:80/im-business';
  static const String authBaseUrl = 'http://120.46.85.43:80/im-auth';
  
  // 认证相关API
  static const String logout = '$authBaseUrl/oauth/logout'; // POST（用户登出）
  
  // 用户相关API（安全版本）
  static const String getUserProfile = '$baseUrl/api/user/profile/me'; // GET（获取当前用户信息）
  static const String updateUserProfile = '$baseUrl/api/user/profile/update'; // PUT（更新当前用户信息）
  static const String updateUserAvatar = '$baseUrl/api/user/profile/avatar'; // PUT（更新当前用户头像）
  
  // 文件上传API
  static const String uploadAvatar = '$baseUrl/api/file/uploadAvatar'; // POST
  
  // 其他API
  static const String userBatchInfo = '$baseUrl/api/user/batchInfo'; // GET
}
