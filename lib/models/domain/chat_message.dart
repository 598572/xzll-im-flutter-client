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
  final int type; // 消息格式（1:文本,2:图片,3:语音等）
  final MessageStatus status;
  @JsonKey(defaultValue: DateTime.timestamp)
  final DateTime timestamp;
  final MessageWithdrawStatus withdrawStatus;
  final String chatId; // 会话ID

  ChatMessage({
    required this.msgId,
    required this.content,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    this.status = MessageStatus.sending, // 默认为发送中状态
    required this.timestamp,
    this.withdrawStatus = MessageWithdrawStatus.no,
    required this.chatId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  // 添加copyWith方法
  ChatMessage copyWith({
    String? msgId,
    String? content,
    String? fromUserId,
    String? toUserId,
    int? type,
    MessageStatus? status,
    DateTime? timestamp,
    MessageWithdrawStatus? withdrawStatus,
    String? chatId,
  }) {
    return ChatMessage(
      msgId: msgId ?? this.msgId,
      content: content ?? this.content,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      withdrawStatus: withdrawStatus ?? this.withdrawStatus,
      chatId: chatId ?? this.chatId,
    );
  }
}
