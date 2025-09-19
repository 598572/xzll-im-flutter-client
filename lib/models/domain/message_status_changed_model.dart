import 'package:xzll_im_flutter_client/models/enum/message_status.dart';

///消息状态变化时的数据模型
class MessageStatusChangedModel {
  final String messageId;
  final MessageStatus messageStatus;

  MessageStatusChangedModel({
    required this.messageId,
    required this.messageStatus,
  });
}
