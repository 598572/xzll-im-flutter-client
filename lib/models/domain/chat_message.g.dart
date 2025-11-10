// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  clientMsgId: json['clientMsgId'] as String,
  msgId: json['msgId'] as String,
  content: json['content'] as String,
  fromUserId: json['fromUserId'] as String,
  toUserId: json['toUserId'] as String,
  type: (json['type'] as num).toInt(),
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.sending,
  timestamp: json['timestamp'] == null
      ? DateTime.timestamp()
      : DateTime.parse(json['timestamp'] as String),
  withdrawStatus:
      $enumDecodeNullable(
        _$MessageWithdrawStatusEnumMap,
        json['withdrawStatus'],
      ) ??
      MessageWithdrawStatus.no,
  chatId: json['chatId'] as String,
);

Map<String, dynamic> _$ChatMessageToJson(
  ChatMessage instance,
) => <String, dynamic>{
  'clientMsgId': instance.clientMsgId,
  'msgId': instance.msgId,
  'content': instance.content,
  'fromUserId': instance.fromUserId,
  'toUserId': instance.toUserId,
  'type': instance.type,
  'status': _$MessageStatusEnumMap[instance.status]!,
  'timestamp': instance.timestamp.toIso8601String(),
  'withdrawStatus': _$MessageWithdrawStatusEnumMap[instance.withdrawStatus]!,
  'chatId': instance.chatId,
};

const _$MessageStatusEnumMap = {
  MessageStatus.fail: -1,
  MessageStatus.sending: 0,
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
