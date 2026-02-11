import '../constant/app_config.dart';

/// API常量类
class ApiConstants {
  // 服务器基础地址 - 使用统一的配置源
  static String get baseUrl => '${AppConfig.baseUrl}/im-business';
  static String get authBaseUrl => '${AppConfig.baseUrl}/im-auth';
  static String get fileBaseUrl => '${AppConfig.baseUrl}/im-business/api/file'; // 文件服务集成在业务服务中
  
  // 认证相关API
  static String get logout => '$authBaseUrl/oauth/logout'; // POST（用户登出）
  
  // 用户相关API（安全版本）
  static String get getUserProfile => '$baseUrl/api/user/profile/me'; // GET（获取当前用户信息）
  static String get updateUserProfile => '$baseUrl/api/user/profile/update'; // PUT（更新当前用户信息）
  static String get updateUserAvatar => '$baseUrl/api/user/profile/avatar'; // PUT（更新当前用户头像）
  
  // 文件上传API
  static String get uploadAvatar => '$baseUrl/api/file/uploadAvatar'; // POST
  
  // 其他API
  static String get userBatchInfo => '$baseUrl/api/user/batchInfo'; // POST（批量获取用户信息）
  
  /// 拼接完整的头像URL
  /// 
  /// 服务器返回的头像路径格式：`s/base64EncodedPath`
  /// 需要拼接为：`${baseUrl}/api/file/s/base64EncodedPath`
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
