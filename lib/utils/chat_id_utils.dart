/// 聊天ID生成工具类
/// 
/// 参考服务端规则生成会话ID
class ChatIdUtils {
  // 业务类型枚举
  static const int bizTypeIM = 100; // BizType.IM.getValue()
  
  // 聊天类型枚举
  static const int chatTypeC2C = 1; // ChatType.C2C.getValue() - 单聊
  static const int chatTypeGroup = 2; // ChatType.GROUP.getValue() - 群聊（预留）

  /// 生成单聊会话ID
  /// 
  /// 规则：bizType-chatType-smallUserId-bigUserId
  /// 例如：100-1-123456-123789
  /// 
  /// [userId1] 第一个用户ID
  /// [userId2] 第二个用户ID
  /// 
  /// Returns 生成的会话ID
  static String generateC2CChatId(String userId1, String userId2) {
    if (userId1.isEmpty || userId2.isEmpty) {
      throw ArgumentError('用户ID不能为空');
    }
    
    // 转换为整数进行比较
    int userId1Int;
    int userId2Int;
    
    try {
      userId1Int = int.parse(userId1);
      userId2Int = int.parse(userId2);
    } catch (e) {
      throw ArgumentError('用户ID必须是数字格式: $e');
    }
    
    // 确定较小和较大的用户ID
    String smallUserId = userId1Int < userId2Int ? userId1 : userId2;
    String bigUserId = userId1Int < userId2Int ? userId2 : userId1;
    
    return buildC2CChatId(bizTypeIM, chatTypeC2C, smallUserId, bigUserId);
  }
  
  /// 构建C2C聊天ID
  /// 
  /// [bizType] 业务类型
  /// [chatType] 聊天类型
  /// [smallUserId] 较小的用户ID
  /// [bigUserId] 较大的用户ID
  /// 
  /// Returns 构建的聊天ID
  static String buildC2CChatId(int bizType, int chatType, String smallUserId, String bigUserId) {
    return '$bizType-$chatType-$smallUserId-$bigUserId';
  }
  
  /// 解析会话ID获取参与的用户ID列表
  /// 
  /// [chatId] 会话ID，格式：bizType-chatType-userId1-userId2
  /// 
  /// Returns 用户ID列表，如果解析失败返回空列表
  static List<String> parseUserIdsFromChatId(String chatId) {
    if (chatId.isEmpty) return [];
    
    try {
      final parts = chatId.split('-');
      if (parts.length >= 4) {
        // 前两部分是bizType和chatType，后面的是用户ID
        return parts.skip(2).toList();
      }
    } catch (e) {
      // 解析失败，返回空列表
    }
    
    return [];
  }
  
  /// 验证会话ID格式是否正确
  /// 
  /// [chatId] 会话ID
  /// 
  /// Returns true表示格式正确
  static bool isValidChatId(String chatId) {
    if (chatId.isEmpty) return false;
    
    try {
      final parts = chatId.split('-');
      if (parts.length < 4) return false;
      
      // 验证bizType和chatType是数字
      int.parse(parts[0]);
      int.parse(parts[1]);
      
      // 验证用户ID是数字
      for (int i = 2; i < parts.length; i++) {
        int.parse(parts[i]);
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 获取会话ID的业务类型
  /// 
  /// [chatId] 会话ID
  /// 
  /// Returns 业务类型，解析失败返回-1
  static int getBizTypeFromChatId(String chatId) {
    try {
      final parts = chatId.split('-');
      if (parts.isNotEmpty) {
        return int.parse(parts[0]);
      }
    } catch (e) {
      // 忽略解析错误
    }
    return -1;
  }
  
  /// 获取会话ID的聊天类型
  /// 
  /// [chatId] 会话ID
  /// 
  /// Returns 聊天类型，解析失败返回-1
  static int getChatTypeFromChatId(String chatId) {
    try {
      final parts = chatId.split('-');
      if (parts.length >= 2) {
        return int.parse(parts[1]);
      }
    } catch (e) {
      // 忽略解析错误
    }
    return -1;
  }
}
