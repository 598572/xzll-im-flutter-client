import 'package:json_annotation/json_annotation.dart';

part 'friend_request.g.dart';

// 好友申请模型
@JsonSerializable()
class FriendRequest {
  final String requestId;
  final String fromUserId;
  final String? fromUserName;
  final String toUserId;
  final String? toUserName;
  final String? requestMessage;
  final int status; // 0-待处理，1-已同意，2-已拒绝，3-已过期
  final DateTime? handleTime;
  @JsonKey(defaultValue: DateTime.now)
  final DateTime createTime;

  FriendRequest({
    required this.requestId,
    required this.fromUserId,
    this.fromUserName,
    required this.toUserId,
    this.toUserName,
    this.requestMessage,
    required this.status,
    this.handleTime,
    required this.createTime,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) => _$FriendRequestFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestToJson(this);

  String get statusText {
    switch (status) {
      case 0:
        return '待处理';
      case 1:
        return '已同意';
      case 2:
        return '已拒绝';
      case 3:
        return '已过期';
      default:
        return '未知';
    }
  }

  bool get isPending => status == 0;
  bool get isAccepted => status == 1;
  bool get isRejected => status == 2;
  bool get isExpired => status == 3;
}
