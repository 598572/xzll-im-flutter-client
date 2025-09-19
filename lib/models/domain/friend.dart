import 'package:json_annotation/json_annotation.dart';

part 'friend.g.dart';

// 好友信息模型
@JsonSerializable()
class Friend {
  final String friendId;
  final String? friendUserName;
  final String? friendFullName;
  final String? friendHeadImage;
  final int? friendSex; // 0-女，1-男，-1-未知
  final bool? blackFlag;
  final DateTime? createTime;

  Friend({
    required this.friendId,
    this.friendUserName,
    this.friendFullName,
    this.friendHeadImage,
    this.friendSex,
    this.blackFlag,
    this.createTime,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);

  Map<String, dynamic> toJson() => _$FriendToJson(this);

  String get displayName => friendFullName ?? friendUserName ?? friendId;
  String get sexText {
    switch (friendSex) {
      case 0:
        return '女';
      case 1:
        return '男';
      default:
        return '未知';
    }
  }
}
