/// 环境配置文件 - 支持多环境配置
/// 
/// 使用方法：
/// 1. 修改 AppConfig 中的 environment 字段来切换环境
/// 2. 或者在编译时通过 --dart-define 参数指定环境
/// 
/// 编译示例：
/// flutter build apk --dart-define=ENVIRONMENT=production
/// flutter run --dart-define=ENVIRONMENT=development

library app_config_env;

import 'app_config.dart';

/// 环境配置类
class AppConfigEnv {
  /// 从环境变量或编译参数获取当前环境
  static AppEnvironment get currentEnvironment {
    const envString = String.fromEnvironment('ENVIRONMENT');
    
    if (envString.isEmpty) {
      // 如果没有指定环境变量，使用 AppConfig 中的默认环境
      return AppConfig.environment;
    }
    
    switch (envString.toLowerCase()) {
      case 'dev':
        return AppEnvironment.dev;
      case 'test':
        return AppEnvironment.test;
      case 'prod':
        return AppEnvironment.prod;
      default:
        return AppConfig.environment;
    }
  }
  
  /// 获取当前环境的服务器配置
  static ServerConfig get serverConfig {
    switch (currentEnvironment) {
      case AppEnvironment.dev:
        return ServerConfig.development();
      case AppEnvironment.test:
        return ServerConfig.testing();
      case AppEnvironment.prod:
        return ServerConfig.production();
    }
  }
}

/// 服务器配置类
class ServerConfig {
  final String host;
  final int httpPort;        // HTTP端口
  final int wsPort;          // WebSocket端口
  final bool useHttps;
  final bool enableDebugLog;
  final int connectionTimeout;
  final int receiveTimeout;
  final int webSocketRetryCount;
  
  const ServerConfig({
    required this.host,
    required this.httpPort,
    required this.wsPort,
    this.useHttps = false,
    this.enableDebugLog = false,
    this.connectionTimeout = 30,
    this.receiveTimeout = 30,
    this.webSocketRetryCount = 3,
  });
  
  /// 个人开发环境配置（适用于在本机启动后台所有服务）
  factory ServerConfig.development() => const ServerConfig(
    host: '192.168.177.218',         // 本机ip 热点时使用此ip
    // host: '10.66.253.227',         // 连wifi
    httpPort: 8081,           // HTTP接口（gateway）端口
    wsPort: 10001,            // WebSocket端口
    useHttps: false,
    enableDebugLog: true,
    connectionTimeout: 30,
    receiveTimeout: 30,
    webSocketRetryCount: 5,
  );
  
  /// 测试环境配置
  factory ServerConfig.testing() => const ServerConfig(
    host: '120.46.85.43',
    httpPort: 80,          // nginx HTTP接口端口
    wsPort: 80,            // nginx WebSocket端口
    useHttps: false,
    enableDebugLog: true,
    connectionTimeout: 20,
    receiveTimeout: 20,
    webSocketRetryCount: 3,
  );
  
  /// 生产环境配置
  factory ServerConfig.production() => const ServerConfig(
    host: '192.168.1.150',
    httpPort: 8081,
    wsPort: 10001,
    useHttps: false,
    enableDebugLog: false,
    connectionTimeout: 15,
    receiveTimeout: 15,
    webSocketRetryCount: 3,
  );
  
  /// HTTP协议基础URL
  String get baseUrl => '${useHttps ? 'https' : 'http'}://$host:$httpPort';
  
  /// WebSocket协议基础URL
  String get wsBaseUrl => '${useHttps ? 'wss' : 'ws'}://$host:$wsPort';
  
  /// WebSocket连接URL
  String getWebSocketUrl(String userId) => '$wsBaseUrl/websocket?userId=$userId';
}
