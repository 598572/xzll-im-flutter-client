import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';

String formatLastMessage(ChatMessage message) {
  // 消息格式（1:文本,2:图片,3:语音,4:视频,5:文件,6:位置）
  switch (message.type) {
    case 1:
      return message.content;
    case 2:
      return "[图片]";
    case 3:
      return "[语音]";
    case 4:
      return "[视频]";
    case 5:
      return "[文件]";
    case 6:
      return "[位置]";
    default:
      return "[未知消息]";
  }
}

String formatMessageTimestamp(DateTime timestamp) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(timestamp);
  if (difference.inDays > 0) {
    return '${difference.inDays}天前';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}小时前';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}分钟前';
  } else {
    return '刚刚';
  }
}

/// 生成chatId
/// 格式: 100-1-{userId1}-{userId2}
/// 其中userId较小的在前，保证同一对话的chatId一致
String generateChatId(String userId1, String userId2) {
  List<String> userIds = [userId1, userId2];
  userIds.sort(); // 按字典序排序
  return '100-1-${userIds[0]}-${userIds[1]}';
}
