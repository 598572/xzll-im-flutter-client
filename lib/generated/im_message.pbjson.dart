// This is a generated file - do not edit.
//
// Generated from im_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use msgTypeDescriptor instead')
const MsgType$json = {
  '1': 'MsgType',
  '2': [
    {'1': 'MSG_TYPE_UNKNOWN', '2': 0},
    {'1': 'C2C_SEND', '2': 1},
    {'1': 'C2C_ACK', '2': 2},
    {'1': 'C2C_WITHDRAW', '2': 3},
    {'1': 'C2C_MSG_PUSH', '2': 5},
    {'1': 'GROUP_SEND', '2': 7},
    {'1': 'GROUP_MSG_PUSH', '2': 8},
    {'1': 'GROUP_ACK', '2': 9},
    {'1': 'GROUP_WITHDRAW', '2': 10},
    {'1': 'FRIEND_REQUEST', '2': 11},
    {'1': 'FRIEND_RESPONSE', '2': 12},
    {'1': 'GET_BATCH_MSG_IDS', '2': 4},
    {'1': 'PUSH_BATCH_MSG_IDS', '2': 6},
  ],
};

/// Descriptor for `MsgType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List msgTypeDescriptor = $convert.base64Decode(
    'CgdNc2dUeXBlEhQKEE1TR19UWVBFX1VOS05PV04QABIMCghDMkNfU0VORBABEgsKB0MyQ19BQ0'
    'sQAhIQCgxDMkNfV0lUSERSQVcQAxIQCgxDMkNfTVNHX1BVU0gQBRIOCgpHUk9VUF9TRU5EEAcS'
    'EgoOR1JPVVBfTVNHX1BVU0gQCBINCglHUk9VUF9BQ0sQCRISCg5HUk9VUF9XSVRIRFJBVxAKEh'
    'IKDkZSSUVORF9SRVFVRVNUEAsSEwoPRlJJRU5EX1JFU1BPTlNFEAwSFQoRR0VUX0JBVENIX01T'
    'R19JRFMQBBIWChJQVVNIX0JBVENIX01TR19JRFMQBg==');

@$core.Deprecated('Use imProtoRequestDescriptor instead')
const ImProtoRequest$json = {
  '1': 'ImProtoRequest',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.xzll.im.MsgType',
      '10': 'type'
    },
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `ImProtoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imProtoRequestDescriptor = $convert.base64Decode(
    'Cg5JbVByb3RvUmVxdWVzdBIkCgR0eXBlGAEgASgOMhAueHpsbC5pbS5Nc2dUeXBlUgR0eXBlEh'
    'gKB3BheWxvYWQYAiABKAxSB3BheWxvYWQ=');

@$core.Deprecated('Use imProtoResponseDescriptor instead')
const ImProtoResponse$json = {
  '1': 'ImProtoResponse',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.xzll.im.MsgType',
      '10': 'type'
    },
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'code', '3': 3, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 4, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `ImProtoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imProtoResponseDescriptor = $convert.base64Decode(
    'Cg9JbVByb3RvUmVzcG9uc2USJAoEdHlwZRgBIAEoDjIQLnh6bGwuaW0uTXNnVHlwZVIEdHlwZR'
    'IYCgdwYXlsb2FkGAIgASgMUgdwYXlsb2FkEhIKBGNvZGUYAyABKAVSBGNvZGUSEAoDbXNnGAQg'
    'ASgJUgNtc2c=');

@$core.Deprecated('Use c2CSendReqDescriptor instead')
const C2CSendReq$json = {
  '1': 'C2CSendReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 9, '10': 'to'},
    {'1': 'format', '3': 4, '4': 1, '5': 5, '10': 'format'},
    {'1': 'content', '3': 5, '4': 1, '5': 9, '10': 'content'},
    {'1': 'time', '3': 6, '4': 1, '5': 3, '10': 'time'},
    {'1': 'chatId', '3': 7, '4': 1, '5': 9, '10': 'chatId'},
  ],
};

/// Descriptor for `C2CSendReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List c2CSendReqDescriptor = $convert.base64Decode(
    'CgpDMkNTZW5kUmVxEhQKBW1zZ0lkGAEgASgJUgVtc2dJZBISCgRmcm9tGAIgASgJUgRmcm9tEg'
    '4KAnRvGAMgASgJUgJ0bxIWCgZmb3JtYXQYBCABKAVSBmZvcm1hdBIYCgdjb250ZW50GAUgASgJ'
    'Ugdjb250ZW50EhIKBHRpbWUYBiABKANSBHRpbWUSFgoGY2hhdElkGAcgASgJUgZjaGF0SWQ=');

@$core.Deprecated('Use c2CAckReqDescriptor instead')
const C2CAckReq$json = {
  '1': 'C2CAckReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 9, '10': 'to'},
    {'1': 'status', '3': 4, '4': 1, '5': 5, '10': 'status'},
    {'1': 'chatId', '3': 5, '4': 1, '5': 9, '10': 'chatId'},
  ],
};

/// Descriptor for `C2CAckReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List c2CAckReqDescriptor = $convert.base64Decode(
    'CglDMkNBY2tSZXESFAoFbXNnSWQYASABKAlSBW1zZ0lkEhIKBGZyb20YAiABKAlSBGZyb20SDg'
    'oCdG8YAyABKAlSAnRvEhYKBnN0YXR1cxgEIAEoBVIGc3RhdHVzEhYKBmNoYXRJZBgFIAEoCVIG'
    'Y2hhdElk');

@$core.Deprecated('Use c2CWithdrawReqDescriptor instead')
const C2CWithdrawReq$json = {
  '1': 'C2CWithdrawReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 9, '10': 'to'},
    {'1': 'chatId', '3': 4, '4': 1, '5': 9, '10': 'chatId'},
  ],
};

/// Descriptor for `C2CWithdrawReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List c2CWithdrawReqDescriptor = $convert.base64Decode(
    'Cg5DMkNXaXRoZHJhd1JlcRIUCgVtc2dJZBgBIAEoCVIFbXNnSWQSEgoEZnJvbRgCIAEoCVIEZn'
    'JvbRIOCgJ0bxgDIAEoCVICdG8SFgoGY2hhdElkGAQgASgJUgZjaGF0SWQ=');

@$core.Deprecated('Use getBatchMsgIdsReqDescriptor instead')
const GetBatchMsgIdsReq$json = {
  '1': 'GetBatchMsgIdsReq',
  '2': [
    {'1': 'userId', '3': 1, '4': 1, '5': 9, '10': 'userId'},
  ],
};

/// Descriptor for `GetBatchMsgIdsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBatchMsgIdsReqDescriptor = $convert.base64Decode(
    'ChFHZXRCYXRjaE1zZ0lkc1JlcRIWCgZ1c2VySWQYASABKAlSBnVzZXJJZA==');

@$core.Deprecated('Use c2CMsgPushDescriptor instead')
const C2CMsgPush$json = {
  '1': 'C2CMsgPush',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 9, '10': 'to'},
    {'1': 'format', '3': 4, '4': 1, '5': 5, '10': 'format'},
    {'1': 'content', '3': 5, '4': 1, '5': 9, '10': 'content'},
    {'1': 'time', '3': 6, '4': 1, '5': 3, '10': 'time'},
    {'1': 'chatId', '3': 7, '4': 1, '5': 9, '10': 'chatId'},
  ],
};

/// Descriptor for `C2CMsgPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List c2CMsgPushDescriptor = $convert.base64Decode(
    'CgpDMkNNc2dQdXNoEhQKBW1zZ0lkGAEgASgJUgVtc2dJZBISCgRmcm9tGAIgASgJUgRmcm9tEg'
    '4KAnRvGAMgASgJUgJ0bxIWCgZmb3JtYXQYBCABKAVSBmZvcm1hdBIYCgdjb250ZW50GAUgASgJ'
    'Ugdjb250ZW50EhIKBHRpbWUYBiABKANSBHRpbWUSFgoGY2hhdElkGAcgASgJUgZjaGF0SWQ=');

@$core.Deprecated('Use batchMsgIdsPushDescriptor instead')
const BatchMsgIdsPush$json = {
  '1': 'BatchMsgIdsPush',
  '2': [
    {'1': 'msgIds', '3': 1, '4': 3, '5': 9, '10': 'msgIds'},
  ],
};

/// Descriptor for `BatchMsgIdsPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchMsgIdsPushDescriptor = $convert
    .base64Decode('Cg9CYXRjaE1zZ0lkc1B1c2gSFgoGbXNnSWRzGAEgAygJUgZtc2dJZHM=');

@$core.Deprecated('Use serverAckPushDescriptor instead')
const ServerAckPush$json = {
  '1': 'ServerAckPush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 9, '10': 'toUserId'},
    {'1': 'msgId', '3': 2, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'chatId', '3': 3, '4': 1, '5': 9, '10': 'chatId'},
    {
      '1': 'msgReceivedStatus',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'msgReceivedStatus'
    },
    {'1': 'ackTextDesc', '3': 5, '4': 1, '5': 9, '10': 'ackTextDesc'},
    {'1': 'receiveTime', '3': 6, '4': 1, '5': 3, '10': 'receiveTime'},
  ],
};

/// Descriptor for `ServerAckPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverAckPushDescriptor = $convert.base64Decode(
    'Cg1TZXJ2ZXJBY2tQdXNoEhoKCHRvVXNlcklkGAEgASgJUgh0b1VzZXJJZBIUCgVtc2dJZBgCIA'
    'EoCVIFbXNnSWQSFgoGY2hhdElkGAMgASgJUgZjaGF0SWQSLAoRbXNnUmVjZWl2ZWRTdGF0dXMY'
    'BCABKAVSEW1zZ1JlY2VpdmVkU3RhdHVzEiAKC2Fja1RleHREZXNjGAUgASgJUgthY2tUZXh0RG'
    'VzYxIgCgtyZWNlaXZlVGltZRgGIAEoA1ILcmVjZWl2ZVRpbWU=');

@$core.Deprecated('Use clientAckPushDescriptor instead')
const ClientAckPush$json = {
  '1': 'ClientAckPush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 9, '10': 'toUserId'},
    {'1': 'msgId', '3': 2, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'chatId', '3': 3, '4': 1, '5': 9, '10': 'chatId'},
    {
      '1': 'msgReceivedStatus',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'msgReceivedStatus'
    },
    {'1': 'ackTextDesc', '3': 5, '4': 1, '5': 9, '10': 'ackTextDesc'},
    {'1': 'receiveTime', '3': 6, '4': 1, '5': 3, '10': 'receiveTime'},
  ],
};

/// Descriptor for `ClientAckPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientAckPushDescriptor = $convert.base64Decode(
    'Cg1DbGllbnRBY2tQdXNoEhoKCHRvVXNlcklkGAEgASgJUgh0b1VzZXJJZBIUCgVtc2dJZBgCIA'
    'EoCVIFbXNnSWQSFgoGY2hhdElkGAMgASgJUgZjaGF0SWQSLAoRbXNnUmVjZWl2ZWRTdGF0dXMY'
    'BCABKAVSEW1zZ1JlY2VpdmVkU3RhdHVzEiAKC2Fja1RleHREZXNjGAUgASgJUgthY2tUZXh0RG'
    'VzYxIgCgtyZWNlaXZlVGltZRgGIAEoA1ILcmVjZWl2ZVRpbWU=');

@$core.Deprecated('Use withdrawPushDescriptor instead')
const WithdrawPush$json = {
  '1': 'WithdrawPush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 9, '10': 'toUserId'},
    {'1': 'msgId', '3': 2, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'chatId', '3': 3, '4': 1, '5': 9, '10': 'chatId'},
    {'1': 'fromUserId', '3': 4, '4': 1, '5': 9, '10': 'fromUserId'},
  ],
};

/// Descriptor for `WithdrawPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withdrawPushDescriptor = $convert.base64Decode(
    'CgxXaXRoZHJhd1B1c2gSGgoIdG9Vc2VySWQYASABKAlSCHRvVXNlcklkEhQKBW1zZ0lkGAIgAS'
    'gJUgVtc2dJZBIWCgZjaGF0SWQYAyABKAlSBmNoYXRJZBIeCgpmcm9tVXNlcklkGAQgASgJUgpm'
    'cm9tVXNlcklk');

@$core.Deprecated('Use friendRequestPushDescriptor instead')
const FriendRequestPush$json = {
  '1': 'FriendRequestPush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 9, '10': 'toUserId'},
    {'1': 'requestId', '3': 2, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'fromUserId', '3': 3, '4': 1, '5': 9, '10': 'fromUserId'},
    {'1': 'fromUserName', '3': 4, '4': 1, '5': 9, '10': 'fromUserName'},
    {'1': 'fromUserAvatar', '3': 5, '4': 1, '5': 9, '10': 'fromUserAvatar'},
    {'1': 'requestMessage', '3': 6, '4': 1, '5': 9, '10': 'requestMessage'},
    {'1': 'status', '3': 7, '4': 1, '5': 5, '10': 'status'},
    {'1': 'createTime', '3': 8, '4': 1, '5': 3, '10': 'createTime'},
    {'1': 'pushTitle', '3': 9, '4': 1, '5': 9, '10': 'pushTitle'},
    {'1': 'pushContent', '3': 10, '4': 1, '5': 9, '10': 'pushContent'},
  ],
};

/// Descriptor for `FriendRequestPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendRequestPushDescriptor = $convert.base64Decode(
    'ChFGcmllbmRSZXF1ZXN0UHVzaBIaCgh0b1VzZXJJZBgBIAEoCVIIdG9Vc2VySWQSHAoJcmVxdW'
    'VzdElkGAIgASgJUglyZXF1ZXN0SWQSHgoKZnJvbVVzZXJJZBgDIAEoCVIKZnJvbVVzZXJJZBIi'
    'Cgxmcm9tVXNlck5hbWUYBCABKAlSDGZyb21Vc2VyTmFtZRImCg5mcm9tVXNlckF2YXRhchgFIA'
    'EoCVIOZnJvbVVzZXJBdmF0YXISJgoOcmVxdWVzdE1lc3NhZ2UYBiABKAlSDnJlcXVlc3RNZXNz'
    'YWdlEhYKBnN0YXR1cxgHIAEoBVIGc3RhdHVzEh4KCmNyZWF0ZVRpbWUYCCABKANSCmNyZWF0ZV'
    'RpbWUSHAoJcHVzaFRpdGxlGAkgASgJUglwdXNoVGl0bGUSIAoLcHVzaENvbnRlbnQYCiABKAlS'
    'C3B1c2hDb250ZW50');

@$core.Deprecated('Use friendResponsePushDescriptor instead')
const FriendResponsePush$json = {
  '1': 'FriendResponsePush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 9, '10': 'toUserId'},
    {'1': 'requestId', '3': 2, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'fromUserId', '3': 3, '4': 1, '5': 9, '10': 'fromUserId'},
    {'1': 'fromUserName', '3': 4, '4': 1, '5': 9, '10': 'fromUserName'},
    {'1': 'fromUserAvatar', '3': 5, '4': 1, '5': 9, '10': 'fromUserAvatar'},
    {'1': 'status', '3': 6, '4': 1, '5': 5, '10': 'status'},
    {'1': 'responseTime', '3': 7, '4': 1, '5': 3, '10': 'responseTime'},
    {'1': 'pushTitle', '3': 8, '4': 1, '5': 9, '10': 'pushTitle'},
    {'1': 'pushContent', '3': 9, '4': 1, '5': 9, '10': 'pushContent'},
  ],
};

/// Descriptor for `FriendResponsePush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendResponsePushDescriptor = $convert.base64Decode(
    'ChJGcmllbmRSZXNwb25zZVB1c2gSGgoIdG9Vc2VySWQYASABKAlSCHRvVXNlcklkEhwKCXJlcX'
    'Vlc3RJZBgCIAEoCVIJcmVxdWVzdElkEh4KCmZyb21Vc2VySWQYAyABKAlSCmZyb21Vc2VySWQS'
    'IgoMZnJvbVVzZXJOYW1lGAQgASgJUgxmcm9tVXNlck5hbWUSJgoOZnJvbVVzZXJBdmF0YXIYBS'
    'ABKAlSDmZyb21Vc2VyQXZhdGFyEhYKBnN0YXR1cxgGIAEoBVIGc3RhdHVzEiIKDHJlc3BvbnNl'
    'VGltZRgHIAEoA1IMcmVzcG9uc2VUaW1lEhwKCXB1c2hUaXRsZRgIIAEoCVIJcHVzaFRpdGxlEi'
    'AKC3B1c2hDb250ZW50GAkgASgJUgtwdXNoQ29udGVudA==');

@$core.Deprecated('Use groupSendReqDescriptor instead')
const GroupSendReq$json = {
  '1': 'GroupSendReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'groupId', '3': 3, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'format', '3': 4, '4': 1, '5': 5, '10': 'format'},
    {'1': 'content', '3': 5, '4': 1, '5': 9, '10': 'content'},
    {'1': 'time', '3': 6, '4': 1, '5': 3, '10': 'time'},
  ],
};

/// Descriptor for `GroupSendReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupSendReqDescriptor = $convert.base64Decode(
    'CgxHcm91cFNlbmRSZXESFAoFbXNnSWQYASABKAlSBW1zZ0lkEhIKBGZyb20YAiABKAlSBGZyb2'
    '0SGAoHZ3JvdXBJZBgDIAEoCVIHZ3JvdXBJZBIWCgZmb3JtYXQYBCABKAVSBmZvcm1hdBIYCgdj'
    'b250ZW50GAUgASgJUgdjb250ZW50EhIKBHRpbWUYBiABKANSBHRpbWU=');

@$core.Deprecated('Use groupMsgPushDescriptor instead')
const GroupMsgPush$json = {
  '1': 'GroupMsgPush',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'fromNickname', '3': 3, '4': 1, '5': 9, '10': 'fromNickname'},
    {'1': 'fromAvatar', '3': 4, '4': 1, '5': 9, '10': 'fromAvatar'},
    {'1': 'groupId', '3': 5, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'groupName', '3': 6, '4': 1, '5': 9, '10': 'groupName'},
    {'1': 'format', '3': 7, '4': 1, '5': 5, '10': 'format'},
    {'1': 'content', '3': 8, '4': 1, '5': 9, '10': 'content'},
    {'1': 'time', '3': 9, '4': 1, '5': 3, '10': 'time'},
    {'1': 'memberCount', '3': 10, '4': 1, '5': 5, '10': 'memberCount'},
  ],
};

/// Descriptor for `GroupMsgPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMsgPushDescriptor = $convert.base64Decode(
    'CgxHcm91cE1zZ1B1c2gSFAoFbXNnSWQYASABKAlSBW1zZ0lkEhIKBGZyb20YAiABKAlSBGZyb2'
    '0SIgoMZnJvbU5pY2tuYW1lGAMgASgJUgxmcm9tTmlja25hbWUSHgoKZnJvbUF2YXRhchgEIAEo'
    'CVIKZnJvbUF2YXRhchIYCgdncm91cElkGAUgASgJUgdncm91cElkEhwKCWdyb3VwTmFtZRgGIA'
    'EoCVIJZ3JvdXBOYW1lEhYKBmZvcm1hdBgHIAEoBVIGZm9ybWF0EhgKB2NvbnRlbnQYCCABKAlS'
    'B2NvbnRlbnQSEgoEdGltZRgJIAEoA1IEdGltZRIgCgttZW1iZXJDb3VudBgKIAEoBVILbWVtYm'
    'VyQ291bnQ=');

@$core.Deprecated('Use groupAckReqDescriptor instead')
const GroupAckReq$json = {
  '1': 'GroupAckReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'userId', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'groupId', '3': 3, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'status', '3': 4, '4': 1, '5': 5, '10': 'status'},
  ],
};

/// Descriptor for `GroupAckReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupAckReqDescriptor = $convert.base64Decode(
    'CgtHcm91cEFja1JlcRIUCgVtc2dJZBgBIAEoCVIFbXNnSWQSFgoGdXNlcklkGAIgASgJUgZ1c2'
    'VySWQSGAoHZ3JvdXBJZBgDIAEoCVIHZ3JvdXBJZBIWCgZzdGF0dXMYBCABKAVSBnN0YXR1cw==');

@$core.Deprecated('Use groupWithdrawReqDescriptor instead')
const GroupWithdrawReq$json = {
  '1': 'GroupWithdrawReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'groupId', '3': 3, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'withdrawTime', '3': 4, '4': 1, '5': 3, '10': 'withdrawTime'},
  ],
};

/// Descriptor for `GroupWithdrawReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupWithdrawReqDescriptor = $convert.base64Decode(
    'ChBHcm91cFdpdGhkcmF3UmVxEhQKBW1zZ0lkGAEgASgJUgVtc2dJZBISCgRmcm9tGAIgASgJUg'
    'Rmcm9tEhgKB2dyb3VwSWQYAyABKAlSB2dyb3VwSWQSIgoMd2l0aGRyYXdUaW1lGAQgASgDUgx3'
    'aXRoZHJhd1RpbWU=');

@$core.Deprecated('Use groupWithdrawPushDescriptor instead')
const GroupWithdrawPush$json = {
  '1': 'GroupWithdrawPush',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 9, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 9, '10': 'from'},
    {'1': 'groupId', '3': 3, '4': 1, '5': 9, '10': 'groupId'},
    {'1': 'operatorNickname', '3': 4, '4': 1, '5': 9, '10': 'operatorNickname'},
    {'1': 'withdrawTime', '3': 5, '4': 1, '5': 3, '10': 'withdrawTime'},
    {'1': 'isAdmin', '3': 6, '4': 1, '5': 8, '10': 'isAdmin'},
  ],
};

/// Descriptor for `GroupWithdrawPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupWithdrawPushDescriptor = $convert.base64Decode(
    'ChFHcm91cFdpdGhkcmF3UHVzaBIUCgVtc2dJZBgBIAEoCVIFbXNnSWQSEgoEZnJvbRgCIAEoCV'
    'IEZnJvbRIYCgdncm91cElkGAMgASgJUgdncm91cElkEioKEG9wZXJhdG9yTmlja25hbWUYBCAB'
    'KAlSEG9wZXJhdG9yTmlja25hbWUSIgoMd2l0aGRyYXdUaW1lGAUgASgDUgx3aXRoZHJhd1RpbW'
    'USGAoHaXNBZG1pbhgGIAEoCFIHaXNBZG1pbg==');
