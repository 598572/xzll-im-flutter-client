// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
  name: json['name'] as String,
  headImage: json['headImage'] as String,
  lastMessage: json['lastMessage'] as String?,
  timestamp: json['timestamp'] as String,
  userId: json['userId'] as String,
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  targetUserId: json['targetUserId'] as String?,
  targetUserName: json['targetUserName'] as String?,
  targetUserAvatar: json['targetUserAvatar'] as String?,
  lastMsgFormat: $enumDecodeNullable(
    _$MessageTypeEnumMap,
    json['lastMsgFormat'],
  ),
  lastMsgId: json['lastMsgId'] as String?,
  lastMsgTime: (json['lastMsgTime'] as num?)?.toInt(),
  chatId: json['chatId'] as String?,
);

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'headImage': instance.headImage,
      'lastMessage': instance.lastMessage,
      'timestamp': instance.timestamp,
      'userId': instance.userId,
      'unreadCount': instance.unreadCount,
      'targetUserId': instance.targetUserId,
      'targetUserName': instance.targetUserName,
      'targetUserAvatar': instance.targetUserAvatar,
      'lastMsgFormat': _$MessageTypeEnumMap[instance.lastMsgFormat],
      'lastMsgId': instance.lastMsgId,
      'lastMsgTime': instance.lastMsgTime,
      'chatId': instance.chatId,
    };

const _$MessageTypeEnumMap = {
  MessageType.unknown: 6,
  MessageType.text: 0,
  MessageType.image: 1,
  MessageType.voice: 2,
  MessageType.video: 3,
  MessageType.file: 4,
  MessageType.location: 5,
};
