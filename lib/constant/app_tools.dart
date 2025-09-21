import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/enum/message_type.dart';

String formatLastMessage(ChatMessage message) {
  switch (message.type) {
    case MessageType.text:
      return message.content;
    case MessageType.image:
      return "[图片]";
    case MessageType.video:
      return "[视频]";
    case MessageType.voice:
      return "[语音]";
    case MessageType.file:
      return "[文件]";
    case MessageType.location:
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
