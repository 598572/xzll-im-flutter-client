// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendRequest _$FriendRequestFromJson(Map<String, dynamic> json) =>
    FriendRequest(
      requestId: json['requestId'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String?,
      toUserId: json['toUserId'] as String,
      toUserName: json['toUserName'] as String?,
      requestMessage: json['requestMessage'] as String?,
      status: (json['status'] as num).toInt(),
      handleTime: json['handleTime'] == null
          ? null
          : DateTime.parse(json['handleTime'] as String),
      createTime: json['createTime'] == null
          ? DateTime.now()
          : DateTime.parse(json['createTime'] as String),
    );

Map<String, dynamic> _$FriendRequestToJson(FriendRequest instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'fromUserId': instance.fromUserId,
      'fromUserName': instance.fromUserName,
      'toUserId': instance.toUserId,
      'toUserName': instance.toUserName,
      'requestMessage': instance.requestMessage,
      'status': instance.status,
      'handleTime': instance.handleTime?.toIso8601String(),
      'createTime': instance.createTime.toIso8601String(),
    };
