// 会话模型
import 'package:json_annotation/json_annotation.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';

part 'conversation.g.dart';

@JsonSerializable()
class Conversation {
  final String name;
  final String headImage;
  final String? lastMessage;
  final String timestamp;
  final String userId;
  @JsonKey(defaultValue: 0)
  final int unreadCount;
  final String? targetUserId; // 对方用户ID
  final String? targetUserName; // 对方用户名
  final String? targetUserAvatar; // 对方头像
  final MessageType? lastMsgFormat; // 最后消息格式 (0:文本, 1:图片, 2:语音等)
  final String? lastMsgId; // 最后消息ID
  final int? lastMsgTime; // 最后消息时间戳

  Conversation({
    required this.name,
    required this.headImage,
    required this.lastMessage,
    required this.timestamp,
    required this.userId,
    required this.unreadCount,
    this.targetUserId,
    this.targetUserName,
    this.targetUserAvatar,
    this.lastMsgFormat,
    this.lastMsgId,
    this.lastMsgTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationToJson(this);

  // 添加copyWith方法
  Conversation copyWith({
    String? name,
    String? headImage,
    String? lastMessage,
    String? timestamp,
    String? userId,
    int? unreadCount,
    String? targetUserId,
    String? targetUserName,
    String? targetUserAvatar,
    MessageType? lastMsgFormat,
    String? lastMsgId,
    int? lastMsgTime,
  }) {
    return Conversation(
      name: name ?? this.name,
      headImage: headImage ?? this.headImage,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      unreadCount: unreadCount ?? this.unreadCount,
      targetUserId: targetUserId ?? this.targetUserId,
      targetUserName: targetUserName ?? this.targetUserName,
      targetUserAvatar: targetUserAvatar ?? this.targetUserAvatar,
      lastMsgFormat: lastMsgFormat ?? this.lastMsgFormat,
      lastMsgId: lastMsgId ?? this.lastMsgId,
      lastMsgTime: lastMsgTime ?? this.lastMsgTime,
    );
  }
}
