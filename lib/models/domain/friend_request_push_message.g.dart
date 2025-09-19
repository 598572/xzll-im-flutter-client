// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request_push_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequestPushMessage _$FriendRequestPushMessageFromJson(
  Map<String, dynamic> json,
) => FriendRequestPushMessage(
  pushType: (json['pushType'] as num).toInt(),
  requestId: json['requestId'] as String,
  fromUserId: json['fromUserId'] as String,
  fromUserName: json['fromUserName'] as String?,
  fromUserAvatar: json['fromUserAvatar'] as String?,
  toUserId: json['toUserId'] as String,
  requestMessage: json['requestMessage'] as String?,
  status: (json['status'] as num).toInt(),
  statusText: json['statusText'] as String?,
  handleTime: json['handleTime'] == null
      ? null
      : DateTime.parse(json['handleTime'] as String),
  createTime: DateTime.parse(json['createTime'] as String),
  pushTitle: json['pushTitle'] as String?,
  pushContent: json['pushContent'] as String?,
);

Map<String, dynamic> _$FriendRequestPushMessageToJson(
  FriendRequestPushMessage instance,
) => <String, dynamic>{
  'pushType': instance.pushType,
  'requestId': instance.requestId,
  'fromUserId': instance.fromUserId,
  'fromUserName': instance.fromUserName,
  'fromUserAvatar': instance.fromUserAvatar,
  'toUserId': instance.toUserId,
  'requestMessage': instance.requestMessage,
  'status': instance.status,
  'statusText': instance.statusText,
  'handleTime': instance.handleTime?.toIso8601String(),
  'createTime': instance.createTime.toIso8601String(),
  'pushTitle': instance.pushTitle,
  'pushContent': instance.pushContent,
};
