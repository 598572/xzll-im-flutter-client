import 'package:json_annotation/json_annotation.dart';

part 'friend.g.dart';

// 好友信息模型
@JsonSerializable()
class Friend {
  final String friendId;
  final String? friendName;
  final String? friendFullName;
  final String? friendAvatar;
  final int? friendSex; // 0-女，1-男，-1-未知
  final bool? blackFlag;
  final DateTime? createTime;

  Friend({
    required this.friendId,
    this.friendName,
    this.friendFullName,
    this.friendAvatar,
    this.friendSex,
    this.blackFlag,
    this.createTime,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);

  Map<String, dynamic> toJson() => _$FriendToJson(this);

  String get displayName => friendFullName ?? friendName ?? friendId;
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
