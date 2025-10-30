// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Friend _$FriendFromJson(Map<String, dynamic> json) => Friend(
  friendId: json['friendId'] as String,
  friendName: json['friendName'] as String?,
  friendFullName: json['friendFullName'] as String?,
  friendAvatar: json['friendAvatar'] as String?,
  friendSex: (json['friendSex'] as num?)?.toInt(),
  blackFlag: json['blackFlag'] as bool?,
  createTime: json['createTime'] == null
      ? null
      : DateTime.parse(json['createTime'] as String),
);

Map<String, dynamic> _$FriendToJson(Friend instance) => <String, dynamic>{
  'friendId': instance.friendId,
  'friendName': instance.friendName,
  'friendFullName': instance.friendFullName,
  'friendAvatar': instance.friendAvatar,
  'friendSex': instance.friendSex,
  'blackFlag': instance.blackFlag,
  'createTime': instance.createTime?.toIso8601String(),
};
