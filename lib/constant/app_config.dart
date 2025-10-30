import 'app_config_env.dart';

/// 应用配置类 - 统一管理所有URL和配置信息
sealed class AppConfig {
  // ==================== 服务器配置 ====================
  
  /// 获取当前环境的服务器配置
  static ServerConfig get _serverConfig => AppConfigEnv.serverConfig;
  
  /// HTTP协议基础URL
  static String get baseUrl => _serverConfig.baseUrl;
  
  /// WebSocket协议基础URL  
  static String get wsBaseUrl => _serverConfig.wsBaseUrl;
  
  // ==================== API端点配置 ====================
  
  /// 认证相关API
  static String get loginUrl => '$baseUrl/xzll/im/auth/login';
  static String get refreshTokenUrl => '$baseUrl/xzll/im/auth/refreshToken';
  static String get logoutUrl => '$baseUrl/xzll/im/auth/logout';
  
  /// 好友相关API
  static String get friendListUrl => '$baseUrl/xzll/im/friend/list';
  static String get addFriendUrl => '$baseUrl/xzll/im/friend/add';
  static String get deleteFriendUrl => '$baseUrl/xzll/im/friend/delete';
  static String get searchUserUrl => '$baseUrl/xzll/im/user/search';
  static String get friendRequestListUrl => '$baseUrl/xzll/im/friend/request/list';
  static String get handleFriendRequestUrl => '$baseUrl/xzll/im/friend/request/handle';
  
  /// 会话相关API
  static String get conversationListUrl => '$baseUrl/xzll/im/conversation/list';
  static String get conversationDeleteUrl => '$baseUrl/xzll/im/conversation/delete';
  
  /// WebSocket连接URL
  static String getWebSocketUrl(String userId) => _serverConfig.getWebSocketUrl(userId);
  
  // ==================== 环境配置 ====================
  
  /// 当前环境（开发、测试、生产）
  /// 临时使用远程服务器，本地开发网络问题解决后改回 development
  static const AppEnvironment environment = AppEnvironment.test;
  
  /// 是否启用调试日志
  static bool get enableDebugLog => _serverConfig.enableDebugLog;
  
  /// 连接超时时间（秒）
  static int get connectionTimeout => _serverConfig.connectionTimeout;
  
  /// 读取超时时间（秒）
  static int get receiveTimeout => _serverConfig.receiveTimeout;
  
  /// WebSocket重连次数
  static int get webSocketRetryCount => _serverConfig.webSocketRetryCount;
}

/// 应用环境枚举
enum AppEnvironment {
  dev('开发环境'),
  test('测试环境'),
  prod('生产环境');
  
  const AppEnvironment(this.description);
  final String description;
}