import 'dart:typed_data';
import 'package:fixnum/fixnum.dart';

/// Protobuf 类型转换工具类
/// 
/// 用于在Protobuf优化后的类型与业务层String类型之间进行转换
/// 对应服务端的 ProtoConverterUtil.java
class ProtoConverterUtil {
  /// UUID String 转 Uint8List (16字节)
  /// 
  /// 将标准UUID字符串(36字符)转换为16字节的二进制表示
  /// 例如: "550e8400-e29b-41d4-a716-446655440000" -> 16 bytes
  /// 
  /// [uuidString] UUID字符串（带连字符的标准格式）
  /// Returns 16字节的Uint8List
  static Uint8List uuidStringToBytes(String uuidString) {
    if (uuidString.isEmpty) {
      return Uint8List(0);
    }

    // 移除UUID中的连字符
    final cleanUuid = uuidString.replaceAll('-', '');
    
    if (cleanUuid.length != 32) {
      throw ArgumentError('无效的UUID格式: $uuidString');
    }

    // 将16进制字符串转换为字节数组
    final bytes = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      final hexByte = cleanUuid.substring(i * 2, i * 2 + 2);
      bytes[i] = int.parse(hexByte, radix: 16);
    }

    return bytes;
  }

  /// Uint8List (16字节) 转 UUID String
  /// 
  /// 将16字节的二进制表示转换为标准UUID字符串
  /// 
  /// [bytes] 16字节的Uint8List
  /// Returns 标准格式的UUID字符串（带连字符）
  static String bytesToUuidString(List<int> bytes) {
    if (bytes.isEmpty || bytes.length != 16) {
      return '';
    }

    // 将字节数组转换为16进制字符串
    final hexString = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    // 格式化为标准UUID格式：xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    return '${hexString.substring(0, 8)}-'
        '${hexString.substring(8, 12)}-'
        '${hexString.substring(12, 16)}-'
        '${hexString.substring(16, 20)}-'
        '${hexString.substring(20, 32)}';
  }

  /// 雪花ID String 转 Int64
  /// 
  /// 将字符串格式的雪花ID转换为Int64类型（用于fixed64字段）
  /// 例如: "1988484031183061064" -> Int64(1988484031183061064)
  /// 
  /// [snowflakeIdString] 雪花ID字符串
  /// Returns Int64类型的雪花ID
  static Int64 snowflakeStringToInt64(String snowflakeIdString) {
    if (snowflakeIdString.isEmpty) {
      return Int64.ZERO;
    }

    try {
      return Int64.parseInt(snowflakeIdString);
    } catch (e) {
      // Error converting snowflake ID, return 0
      return Int64.ZERO;
    }
  }

  /// Int64 转 雪花ID String
  /// 
  /// 将Int64类型的雪花ID转换为字符串格式
  /// 
  /// [snowflakeId] Int64类型的雪花ID
  /// Returns 字符串格式的雪花ID
  static String int64ToSnowflakeString(Int64 snowflakeId) {
    return snowflakeId.toString();
  }

  /// String content 转 Uint8List
  /// 
  /// 将消息内容字符串转换为UTF-8编码的字节数组
  /// 
  /// [content] 消息内容字符串
  /// Returns UTF-8编码的Uint8List
  static Uint8List contentStringToBytes(String content) {
    if (content.isEmpty) {
      return Uint8List(0);
    }
    
    // Dart的String.codeUnits返回UTF-16编码
    // 我们需要UTF-8编码，使用dart:convert
    final utf8Bytes = content.codeUnits;
    return Uint8List.fromList(utf8Bytes);
  }

  /// Uint8List 转 String content
  /// 
  /// 将UTF-8编码的字节数组转换为消息内容字符串
  /// 
  /// [bytes] UTF-8编码的Uint8List
  /// Returns 消息内容字符串
  static String bytesToContentString(List<int> bytes) {
    if (bytes.isEmpty) {
      return '';
    }
    
    // 从UTF-8字节数组解码为字符串
    return String.fromCharCodes(bytes);
  }

  /// long 转 Int64 (用于Java long类型的直接转换)
  /// 
  /// [value] Dart int类型的值
  /// Returns Int64类型
  static Int64 intToInt64(int value) {
    return Int64(value);
  }

  /// Int64 转 int (注意：可能会溢出)
  /// 
  /// [value] Int64类型的值
  /// Returns Dart int类型（如果值超出int范围会溢出）
  static int int64ToInt(Int64 value) {
    return value.toInt();
  }

  /// 批量转换：String雪花ID列表 -> Int64列表
  /// 
  /// [idStrings] 雪花ID字符串列表
  /// Returns Int64列表
  static List<Int64> snowflakeStringsToInt64List(List<String> idStrings) {
    return idStrings.map((id) => snowflakeStringToInt64(id)).toList();
  }

  /// 批量转换：Int64列表 -> String雪花ID列表
  /// 
  /// [ids] Int64列表
  /// Returns 雪花ID字符串列表
  static List<String> int64ListToSnowflakeStrings(List<Int64> ids) {
    return ids.map((id) => int64ToSnowflakeString(id)).toList();
  }

  /// 验证UUID字符串格式是否正确
  /// 
  /// [uuidString] UUID字符串
  /// Returns true表示格式正确
  static bool isValidUuid(String uuidString) {
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidPattern.hasMatch(uuidString);
  }

  /// 验证雪花ID字符串格式是否正确
  /// 
  /// [snowflakeIdString] 雪花ID字符串
  /// Returns true表示格式正确（纯数字且长度合理）
  static bool isValidSnowflakeId(String snowflakeIdString) {
    if (snowflakeIdString.isEmpty) {
      return false;
    }
    
    // 雪花ID通常是19位数字
    if (snowflakeIdString.length < 15 || snowflakeIdString.length > 20) {
      return false;
    }
    
    // 验证是否全是数字
    return int.tryParse(snowflakeIdString) != null;
  }
}

