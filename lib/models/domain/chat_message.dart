import 'package:json_annotation/json_annotation.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';

part 'chat_message.g.dart';

/// 消息模型
@JsonSerializable()
class ChatMessage {
  final String msgId;
  final String content;
  final String fromUserId;
  final String toUserId;
  final MessageType type;
  final MessageStatus status;
  @JsonKey(defaultValue: DateTime.timestamp)
  final DateTime timestamp;
  final MessageWithdrawStatus withdrawStatus;

  ChatMessage({
    required this.msgId,
    required this.content,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    this.status = MessageStatus.serverReceived,
    required this.timestamp,
    this.withdrawStatus = MessageWithdrawStatus.no,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}
