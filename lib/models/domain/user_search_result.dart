import 'package:json_annotation/json_annotation.dart';

part 'user_search_result.g.dart';

// 用户搜索结果模型
@JsonSerializable()
class UserSearchResult {
  final String userId;
  final String? userName;
  final String? userFullName;
  final String? headImage;
  final int? sex;
  final String? phoneHidden;
  final String? emailHidden;
  @JsonKey(defaultValue: 0)
  final int friendStatus; // 0-非好友，1-已是好友，2-已发送申请待处理，3-已被拉黑
  final String? friendStatusText;
  final DateTime? registerTime;
  @JsonKey(defaultValue: false)
  final bool canSendRequest;
  final String? pendingRequestId;

  UserSearchResult({
    required this.userId,
    this.userName,
    this.userFullName,
    this.headImage,
    this.sex,
    this.phoneHidden,
    this.emailHidden,
    required this.friendStatus,
    this.friendStatusText,
    this.registerTime,
    required this.canSendRequest,
    this.pendingRequestId,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) => _$UserSearchResultFromJson(json);

  String get displayName => userFullName ?? userName ?? userId;
  String get sexText {
    switch (sex) {
      case 0:
        return '女';
      case 1:
        return '男';
      default:
        return '未知';
    }
  }

  bool get isFriend => friendStatus == 1;
  bool get hasPendingRequest => friendStatus == 2;
  bool get isBlocked => friendStatus == 3;
  bool get isStranger => friendStatus == 0;
}
