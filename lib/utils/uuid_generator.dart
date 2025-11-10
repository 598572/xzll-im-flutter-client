import 'package:uuid/uuid.dart';

/// UUID 生成器 - 用于生成客户端消息ID
/// 
/// 使用标准的 UUID v4 算法生成全局唯一的客户端消息ID
/// clientMsgId 用于：
/// - 客户端消息去重
/// - 消息重试时的精确匹配
/// - ACK 确认时的消息关联
class UuidGenerator {
  static final Uuid _uuid = const Uuid();

  /// 生成客户端消息ID (UUID v4)
  /// 返回格式: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx (36字符)
  /// 
  /// 示例: "550e8400-e29b-41d4-a716-446655440000"
  static String generateClientMsgId() {
    return _uuid.v4();
  }

  /// 生成不带连字符的客户端消息ID (32字符)
  /// 
  /// 示例: "550e8400e29b41d4a716446655440000"
  static String generateCompactClientMsgId() {
    return _uuid.v4().replaceAll('-', '');
  }
}

