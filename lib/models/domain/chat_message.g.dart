// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  msgId: json['msgId'] as String,
  content: json['content'] as String,
  fromUserId: json['fromUserId'] as String,
  toUserId: json['toUserId'] as String,
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.serverReceived,
  timestamp: json['timestamp'] == null
      ? DateTime.timestamp()
      : DateTime.parse(json['timestamp'] as String),
  withdrawStatus:
      $enumDecodeNullable(
        _$MessageWithdrawStatusEnumMap,
        json['withdrawStatus'],
      ) ??
      MessageWithdrawStatus.no,
);

Map<String, dynamic> _$ChatMessageToJson(
  ChatMessage instance,
) => <String, dynamic>{
  'msgId': instance.msgId,
  'content': instance.content,
  'fromUserId': instance.fromUserId,
  'toUserId': instance.toUserId,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'status': _$MessageStatusEnumMap[instance.status]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'withdrawStatus': _$MessageWithdrawStatusEnumMap[instance.withdrawStatus]!,
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

const _$MessageStatusEnumMap = {
  MessageStatus.fail: -1,
  MessageStatus.serverReceived: 1,
  MessageStatus.offLine: 2,
  MessageStatus.unRead: 3,
  MessageStatus.readed: 4,
  MessageStatus.withdraw: 5,
};

const _$MessageWithdrawStatusEnumMap = {
  MessageWithdrawStatus.no: 0,
  MessageWithdrawStatus.yes: 1,
};
