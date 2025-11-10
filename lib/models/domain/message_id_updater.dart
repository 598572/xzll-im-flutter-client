import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';

/// 消息ID更新器 - 处理双轨制ID的映射和更新
/// 
/// 职责：
/// 1. 收到 SERVER_ACK 后，用 clientMsgId 匹配消息并更新 serverMsgId
/// 2. 撤回/删除等操作时，支持用 clientMsgId 或 serverMsgId 查找消息
class MessageIdUpdater {
  /// 在消息列表中查找消息（支持双ID匹配）
  /// 
  /// 优先使用 clientMsgId 匹配（因为发送阶段主要用这个）
  /// 如果 clientMsgId 找不到，再尝试 serverMsgId（撤回等操作时用）
  static int findMessageIndex(List<ChatMessage> messages, String messageId) {
    // 1. 先尝试用 clientMsgId 匹配（发送中的消息用这个）
    int index = messages.indexWhere((m) => m.clientMsgId == messageId);
    if (index != -1) {
      info("📍 通过 clientMsgId 找到消息: $messageId");
      return index;
    }
    
    // 2. 再尝试用 serverMsgId 匹配（已发送成功的消息用这个）
    index = messages.indexWhere((m) => m.msgId == messageId);
    if (index != -1) {
      info("📍 通过 serverMsgId 找到消息: $messageId");
      return index;
    }
    
    waring("⚠️ 未找到消息: $messageId");
    return -1;
  }
  
  /// 更新消息的 serverMsgId（收到 SERVER_ACK 后调用）
  /// 
  /// 用 clientMsgId 找到消息，然后更新其 serverMsgId
  /// 这样后续的撤回/删除操作就可以用 serverMsgId 了
  static ChatMessage? updateServerMsgId(
    List<ChatMessage> messages, 
    String clientMsgId, 
    String serverMsgId,
  ) {
    int index = messages.indexWhere((m) => m.clientMsgId == clientMsgId);
    
    if (index == -1) {
      waring("⚠️ 未找到消息（clientMsgId: $clientMsgId），无法更新 serverMsgId");
      return null;
    }
    
    // 检查是否已经有 serverMsgId
    if (messages[index].msgId.isNotEmpty && messages[index].msgId != serverMsgId) {
      waring("⚠️ 消息已有不同的 serverMsgId: ${messages[index].msgId} != $serverMsgId");
    }
    
    // 更新 serverMsgId
    ChatMessage updatedMessage = messages[index].copyWith(msgId: serverMsgId);
    messages[index] = updatedMessage;
    
    info("✅ 更新消息 serverMsgId: clientMsgId=$clientMsgId, serverMsgId=$serverMsgId");
    return updatedMessage;
  }
  
  /// 检查消息是否已有 serverMsgId（用于撤回等操作前的校验）
  static bool hasServerMsgId(ChatMessage message) {
    return message.msgId.isNotEmpty;
  }
  
  /// 获取消息的描述信息（用于日志）
  static String getMessageIdInfo(ChatMessage message) {
    return "clientMsgId=${message.clientMsgId}, serverMsgId=${message.msgId.isEmpty ? '(未生成)' : message.msgId}";
  }
}

