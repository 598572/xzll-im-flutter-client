/// API常量类
class ApiConstants {
  // 服务器基础地址
  static const String baseUrl = 'http://120.46.85.43:80/im-business';
  static const String authBaseUrl = 'http://120.46.85.43:80/im-auth';
  static const String fileBaseUrl = 'http://120.46.85.43:80/im-business/api/file'; // 文件服务集成在业务服务中
  
  // 认证相关API
  static const String logout = '$authBaseUrl/oauth/logout'; // POST（用户登出）
  
  // 用户相关API（安全版本）
  static const String getUserProfile = '$baseUrl/api/user/profile/me'; // GET（获取当前用户信息）
  static const String updateUserProfile = '$baseUrl/api/user/profile/update'; // PUT（更新当前用户信息）
  static const String updateUserAvatar = '$baseUrl/api/user/profile/avatar'; // PUT（更新当前用户头像）
  
  // 文件上传API
  static const String uploadAvatar = '$baseUrl/api/file/uploadAvatar'; // POST
  
  // 其他API
  static const String userBatchInfo = '$baseUrl/api/user/batchInfo'; // POST（批量获取用户信息）
  
  /// 拼接完整的头像URL
  /// 
  /// 服务器返回的头像路径格式：`s/base64EncodedPath`
  /// 需要拼接为：`http://120.46.85.43:80/im-business/api/file/s/base64EncodedPath`
  static String getFullAvatarUrl(String? avatarPath) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return '';
    }
    
    // 如果已经是完整URL，直接返回
    if (avatarPath.startsWith('http://') || avatarPath.startsWith('https://')) {
      return avatarPath;
    }
    
    // 拼接完整URL
    return '$fileBaseUrl/$avatarPath';
  }
}
