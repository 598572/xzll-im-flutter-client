import 'package:json_annotation/json_annotation.dart';

part 'friend_request_push_message.g.dart';

// 好友申请推送消息模型
@JsonSerializable()
class FriendRequestPushMessage {
  final int pushType; // 1-新的好友申请，2-好友申请处理结果
  final String requestId;
  final String fromUserId;
  final String? fromUserName;
  final String? fromUserAvatar;
  final String toUserId;
  final String? requestMessage;
  final int status;
  final String? statusText;
  final DateTime? handleTime;
  final DateTime createTime;
  final String? pushTitle;
  final String? pushContent;

  FriendRequestPushMessage({
    required this.pushType,
    required this.requestId,
    required this.fromUserId,
    this.fromUserName,
    this.fromUserAvatar,
    required this.toUserId,
    this.requestMessage,
    required this.status,
    this.statusText,
    this.handleTime,
    required this.createTime,
    this.pushTitle,
    this.pushContent,
  });

  factory FriendRequestPushMessage.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestPushMessageFromJson(json);

  bool get isNewRequest => pushType == 1;
  bool get isHandleResult => pushType == 2;
}
