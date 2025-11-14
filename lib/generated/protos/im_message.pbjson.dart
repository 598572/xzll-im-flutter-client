// This is a generated file - do not edit.
//
// Generated from protos/im_message.proto.

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

@$core.Deprecated('Use webBaseResponseDescriptor instead')
const WebBaseResponse$json = {
  '1': 'WebBaseResponse',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'data', '3': 3, '4': 1, '5': 9, '10': 'data'},
    {'1': 'success', '3': 4, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `WebBaseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List webBaseResponseDescriptor = $convert.base64Decode(
    'Cg9XZWJCYXNlUmVzcG9uc2USEgoEY29kZRgBIAEoBVIEY29kZRIYCgdtZXNzYWdlGAIgASgJUg'
    'dtZXNzYWdlEhIKBGRhdGEYAyABKAlSBGRhdGESGAoHc3VjY2VzcxgEIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use imProtoRequestDescriptor instead')
const ImProtoRequest$json = {
  '1': 'ImProtoRequest',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.com.xzll.grpc.MsgType',
      '10': 'type'
    },
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `ImProtoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imProtoRequestDescriptor = $convert.base64Decode(
    'Cg5JbVByb3RvUmVxdWVzdBIqCgR0eXBlGAEgASgOMhYuY29tLnh6bGwuZ3JwYy5Nc2dUeXBlUg'
    'R0eXBlEhgKB3BheWxvYWQYAiABKAxSB3BheWxvYWQ=');

@$core.Deprecated('Use imProtoResponseDescriptor instead')
const ImProtoResponse$json = {
  '1': 'ImProtoResponse',
  '2': [
    {
      '1': 'type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.com.xzll.grpc.MsgType',
      '10': 'type'
    },
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'code', '3': 3, '4': 1, '5': 5, '10': 'code'},
    {'1': 'msg', '3': 4, '4': 1, '5': 9, '10': 'msg'},
  ],
};

/// Descriptor for `ImProtoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imProtoResponseDescriptor = $convert.base64Decode(
    'Cg9JbVByb3RvUmVzcG9uc2USKgoEdHlwZRgBIAEoDjIWLmNvbS54emxsLmdycGMuTXNnVHlwZV'
    'IEdHlwZRIYCgdwYXlsb2FkGAIgASgMUgdwYXlsb2FkEhIKBGNvZGUYAyABKAVSBGNvZGUSEAoD'
    'bXNnGAQgASgJUgNtc2c=');

@$core.Deprecated('Use c2CSendReqDescriptor instead')
const C2CSendReq$json = {
  '1': 'C2CSendReq',
  '2': [
    {'1': 'clientMsgId', '3': 1, '4': 1, '5': 12, '10': 'clientMsgId'},
    {'1': 'msgId', '3': 2, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'from', '3': 3, '4': 1, '5': 6, '10': 'from'},
    {'1': 'to', '3': 4, '4': 1, '5': 6, '10': 'to'},
    {'1': 'format', '3': 5, '4': 1, '5': 5, '10': 'format'},
    {'1': 'content', '3': 6, '4': 1, '5': 9, '10': 'content'},
    {'1': 'time', '3': 7, '4': 1, '5': 6, '10': 'time'},
  ],
};

/// Descriptor for `C2CSendReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List c2CSendReqDescriptor = $convert.base64Decode(
    'CgpDMkNTZW5kUmVxEiAKC2NsaWVudE1zZ0lkGAEgASgMUgtjbGllbnRNc2dJZBIUCgVtc2dJZB'
    'gCIAEoBlIFbXNnSWQSEgoEZnJvbRgDIAEoBlIEZnJvbRIOCgJ0bxgEIAEoBlICdG8SFgoGZm9y'
    'bWF0GAUgASgFUgZmb3JtYXQSGAoHY29udGVudBgGIAEoCVIHY29udGVudBISCgR0aW1lGAcgAS'
    'gGUgR0aW1l');

@$core.Deprecated('Use c2CAckReqDescriptor instead')
const C2CAckReq$json = {
  '1': 'C2CAckReq',
  '2': [
    {'1': 'clientMsgId', '3': 1, '4': 1, '5': 12, '10': 'clientMsgId'},
    {'1': 'msgId', '3': 2, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'from', '3': 3, '4': 1, '5': 6, '10': 'from'},
    {'1': 'to', '3': 4, '4': 1, '5': 6, '10': 'to'},
    {'1': 'status', '3': 5, '4': 1, '5': 5, '10': 'status'},
  ],
};

/// Descriptor for `C2CAckReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List c2CAckReqDescriptor = $convert.base64Decode(
    'CglDMkNBY2tSZXESIAoLY2xpZW50TXNnSWQYASABKAxSC2NsaWVudE1zZ0lkEhQKBW1zZ0lkGA'
    'IgASgGUgVtc2dJZBISCgRmcm9tGAMgASgGUgRmcm9tEg4KAnRvGAQgASgGUgJ0bxIWCgZzdGF0'
    'dXMYBSABKAVSBnN0YXR1cw==');

@$core.Deprecated('Use c2CWithdrawReqDescriptor instead')
const C2CWithdrawReq$json = {
  '1': 'C2CWithdrawReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 6, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 6, '10': 'to'},
  ],
};

/// Descriptor for `C2CWithdrawReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List c2CWithdrawReqDescriptor = $convert.base64Decode(
    'Cg5DMkNXaXRoZHJhd1JlcRIUCgVtc2dJZBgBIAEoBlIFbXNnSWQSEgoEZnJvbRgCIAEoBlIEZn'
    'JvbRIOCgJ0bxgDIAEoBlICdG8=');

@$core.Deprecated('Use getBatchMsgIdsReqDescriptor instead')
const GetBatchMsgIdsReq$json = {
  '1': 'GetBatchMsgIdsReq',
  '2': [
    {'1': 'userId', '3': 1, '4': 1, '5': 6, '10': 'userId'},
  ],
};

/// Descriptor for `GetBatchMsgIdsReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBatchMsgIdsReqDescriptor = $convert.base64Decode(
    'ChFHZXRCYXRjaE1zZ0lkc1JlcRIWCgZ1c2VySWQYASABKAZSBnVzZXJJZA==');

@$core.Deprecated('Use c2CMsgPushDescriptor instead')
const C2CMsgPush$json = {
  '1': 'C2CMsgPush',
  '2': [
    {'1': 'clientMsgId', '3': 1, '4': 1, '5': 12, '10': 'clientMsgId'},
    {'1': 'msgId', '3': 2, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'from', '3': 3, '4': 1, '5': 6, '10': 'from'},
    {'1': 'to', '3': 4, '4': 1, '5': 6, '10': 'to'},
    {'1': 'format', '3': 5, '4': 1, '5': 5, '10': 'format'},
    {'1': 'content', '3': 6, '4': 1, '5': 9, '10': 'content'},
    {'1': 'time', '3': 7, '4': 1, '5': 6, '10': 'time'},
  ],
};

/// Descriptor for `C2CMsgPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List c2CMsgPushDescriptor = $convert.base64Decode(
    'CgpDMkNNc2dQdXNoEiAKC2NsaWVudE1zZ0lkGAEgASgMUgtjbGllbnRNc2dJZBIUCgVtc2dJZB'
    'gCIAEoBlIFbXNnSWQSEgoEZnJvbRgDIAEoBlIEZnJvbRIOCgJ0bxgEIAEoBlICdG8SFgoGZm9y'
    'bWF0GAUgASgFUgZmb3JtYXQSGAoHY29udGVudBgGIAEoCVIHY29udGVudBISCgR0aW1lGAcgAS'
    'gGUgR0aW1l');

@$core.Deprecated('Use batchMsgIdsPushDescriptor instead')
const BatchMsgIdsPush$json = {
  '1': 'BatchMsgIdsPush',
  '2': [
    {'1': 'msgIds', '3': 1, '4': 3, '5': 6, '10': 'msgIds'},
  ],
};

/// Descriptor for `BatchMsgIdsPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchMsgIdsPushDescriptor = $convert
    .base64Decode('Cg9CYXRjaE1zZ0lkc1B1c2gSFgoGbXNnSWRzGAEgAygGUgZtc2dJZHM=');

@$core.Deprecated('Use serverAckPushDescriptor instead')
const ServerAckPush$json = {
  '1': 'ServerAckPush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 6, '10': 'toUserId'},
    {'1': 'clientMsgId', '3': 2, '4': 1, '5': 12, '10': 'clientMsgId'},
    {'1': 'msgId', '3': 3, '4': 1, '5': 6, '10': 'msgId'},
    {
      '1': 'msgReceivedStatus',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'msgReceivedStatus'
    },
    {'1': 'receiveTime', '3': 7, '4': 1, '5': 6, '10': 'receiveTime'},
  ],
};

/// Descriptor for `ServerAckPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List serverAckPushDescriptor = $convert.base64Decode(
    'Cg1TZXJ2ZXJBY2tQdXNoEhoKCHRvVXNlcklkGAEgASgGUgh0b1VzZXJJZBIgCgtjbGllbnRNc2'
    'dJZBgCIAEoDFILY2xpZW50TXNnSWQSFAoFbXNnSWQYAyABKAZSBW1zZ0lkEiwKEW1zZ1JlY2Vp'
    'dmVkU3RhdHVzGAUgASgFUhFtc2dSZWNlaXZlZFN0YXR1cxIgCgtyZWNlaXZlVGltZRgHIAEoBl'
    'ILcmVjZWl2ZVRpbWU=');

@$core.Deprecated('Use clientAckPushDescriptor instead')
const ClientAckPush$json = {
  '1': 'ClientAckPush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 6, '10': 'toUserId'},
    {'1': 'clientMsgId', '3': 2, '4': 1, '5': 12, '10': 'clientMsgId'},
    {'1': 'msgId', '3': 3, '4': 1, '5': 6, '10': 'msgId'},
    {
      '1': 'msgReceivedStatus',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'msgReceivedStatus'
    },
    {'1': 'receiveTime', '3': 7, '4': 1, '5': 6, '10': 'receiveTime'},
  ],
};

/// Descriptor for `ClientAckPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientAckPushDescriptor = $convert.base64Decode(
    'Cg1DbGllbnRBY2tQdXNoEhoKCHRvVXNlcklkGAEgASgGUgh0b1VzZXJJZBIgCgtjbGllbnRNc2'
    'dJZBgCIAEoDFILY2xpZW50TXNnSWQSFAoFbXNnSWQYAyABKAZSBW1zZ0lkEiwKEW1zZ1JlY2Vp'
    'dmVkU3RhdHVzGAUgASgFUhFtc2dSZWNlaXZlZFN0YXR1cxIgCgtyZWNlaXZlVGltZRgHIAEoBl'
    'ILcmVjZWl2ZVRpbWU=');

@$core.Deprecated('Use withdrawPushDescriptor instead')
const WithdrawPush$json = {
  '1': 'WithdrawPush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 6, '10': 'toUserId'},
    {'1': 'msgId', '3': 2, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'fromUserId', '3': 4, '4': 1, '5': 6, '10': 'fromUserId'},
  ],
};

/// Descriptor for `WithdrawPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List withdrawPushDescriptor = $convert.base64Decode(
    'CgxXaXRoZHJhd1B1c2gSGgoIdG9Vc2VySWQYASABKAZSCHRvVXNlcklkEhQKBW1zZ0lkGAIgAS'
    'gGUgVtc2dJZBIeCgpmcm9tVXNlcklkGAQgASgGUgpmcm9tVXNlcklk');

@$core.Deprecated('Use friendRequestPushDescriptor instead')
const FriendRequestPush$json = {
  '1': 'FriendRequestPush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 6, '10': 'toUserId'},
    {'1': 'requestId', '3': 2, '4': 1, '5': 6, '10': 'requestId'},
    {'1': 'fromUserId', '3': 3, '4': 1, '5': 6, '10': 'fromUserId'},
    {'1': 'fromUserName', '3': 4, '4': 1, '5': 9, '10': 'fromUserName'},
    {'1': 'fromUserAvatar', '3': 5, '4': 1, '5': 9, '10': 'fromUserAvatar'},
    {'1': 'requestMessage', '3': 6, '4': 1, '5': 9, '10': 'requestMessage'},
    {'1': 'status', '3': 7, '4': 1, '5': 5, '10': 'status'},
    {'1': 'createTime', '3': 8, '4': 1, '5': 6, '10': 'createTime'},
    {'1': 'pushTitle', '3': 9, '4': 1, '5': 9, '10': 'pushTitle'},
    {'1': 'pushContent', '3': 10, '4': 1, '5': 9, '10': 'pushContent'},
  ],
};

/// Descriptor for `FriendRequestPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendRequestPushDescriptor = $convert.base64Decode(
    'ChFGcmllbmRSZXF1ZXN0UHVzaBIaCgh0b1VzZXJJZBgBIAEoBlIIdG9Vc2VySWQSHAoJcmVxdW'
    'VzdElkGAIgASgGUglyZXF1ZXN0SWQSHgoKZnJvbVVzZXJJZBgDIAEoBlIKZnJvbVVzZXJJZBIi'
    'Cgxmcm9tVXNlck5hbWUYBCABKAlSDGZyb21Vc2VyTmFtZRImCg5mcm9tVXNlckF2YXRhchgFIA'
    'EoCVIOZnJvbVVzZXJBdmF0YXISJgoOcmVxdWVzdE1lc3NhZ2UYBiABKAlSDnJlcXVlc3RNZXNz'
    'YWdlEhYKBnN0YXR1cxgHIAEoBVIGc3RhdHVzEh4KCmNyZWF0ZVRpbWUYCCABKAZSCmNyZWF0ZV'
    'RpbWUSHAoJcHVzaFRpdGxlGAkgASgJUglwdXNoVGl0bGUSIAoLcHVzaENvbnRlbnQYCiABKAlS'
    'C3B1c2hDb250ZW50');

@$core.Deprecated('Use friendResponsePushDescriptor instead')
const FriendResponsePush$json = {
  '1': 'FriendResponsePush',
  '2': [
    {'1': 'toUserId', '3': 1, '4': 1, '5': 6, '10': 'toUserId'},
    {'1': 'requestId', '3': 2, '4': 1, '5': 6, '10': 'requestId'},
    {'1': 'fromUserId', '3': 3, '4': 1, '5': 6, '10': 'fromUserId'},
    {'1': 'fromUserName', '3': 4, '4': 1, '5': 9, '10': 'fromUserName'},
    {'1': 'fromUserAvatar', '3': 5, '4': 1, '5': 9, '10': 'fromUserAvatar'},
    {'1': 'status', '3': 6, '4': 1, '5': 5, '10': 'status'},
    {'1': 'responseTime', '3': 7, '4': 1, '5': 6, '10': 'responseTime'},
    {'1': 'pushTitle', '3': 8, '4': 1, '5': 9, '10': 'pushTitle'},
    {'1': 'pushContent', '3': 9, '4': 1, '5': 9, '10': 'pushContent'},
  ],
};

/// Descriptor for `FriendResponsePush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List friendResponsePushDescriptor = $convert.base64Decode(
    'ChJGcmllbmRSZXNwb25zZVB1c2gSGgoIdG9Vc2VySWQYASABKAZSCHRvVXNlcklkEhwKCXJlcX'
    'Vlc3RJZBgCIAEoBlIJcmVxdWVzdElkEh4KCmZyb21Vc2VySWQYAyABKAZSCmZyb21Vc2VySWQS'
    'IgoMZnJvbVVzZXJOYW1lGAQgASgJUgxmcm9tVXNlck5hbWUSJgoOZnJvbVVzZXJBdmF0YXIYBS'
    'ABKAlSDmZyb21Vc2VyQXZhdGFyEhYKBnN0YXR1cxgGIAEoBVIGc3RhdHVzEiIKDHJlc3BvbnNl'
    'VGltZRgHIAEoBlIMcmVzcG9uc2VUaW1lEhwKCXB1c2hUaXRsZRgIIAEoCVIJcHVzaFRpdGxlEi'
    'AKC3B1c2hDb250ZW50GAkgASgJUgtwdXNoQ29udGVudA==');

@$core.Deprecated('Use groupSendReqDescriptor instead')
const GroupSendReq$json = {
  '1': 'GroupSendReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 6, '10': 'from'},
    {'1': 'groupId', '3': 3, '4': 1, '5': 6, '10': 'groupId'},
    {'1': 'format', '3': 4, '4': 1, '5': 5, '10': 'format'},
    {'1': 'content', '3': 5, '4': 1, '5': 9, '10': 'content'},
    {'1': 'time', '3': 6, '4': 1, '5': 6, '10': 'time'},
  ],
};

/// Descriptor for `GroupSendReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupSendReqDescriptor = $convert.base64Decode(
    'CgxHcm91cFNlbmRSZXESFAoFbXNnSWQYASABKAZSBW1zZ0lkEhIKBGZyb20YAiABKAZSBGZyb2'
    '0SGAoHZ3JvdXBJZBgDIAEoBlIHZ3JvdXBJZBIWCgZmb3JtYXQYBCABKAVSBmZvcm1hdBIYCgdj'
    'b250ZW50GAUgASgJUgdjb250ZW50EhIKBHRpbWUYBiABKAZSBHRpbWU=');

@$core.Deprecated('Use groupMsgPushDescriptor instead')
const GroupMsgPush$json = {
  '1': 'GroupMsgPush',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 6, '10': 'from'},
    {'1': 'fromNickname', '3': 3, '4': 1, '5': 9, '10': 'fromNickname'},
    {'1': 'fromAvatar', '3': 4, '4': 1, '5': 9, '10': 'fromAvatar'},
    {'1': 'groupId', '3': 5, '4': 1, '5': 6, '10': 'groupId'},
    {'1': 'groupName', '3': 6, '4': 1, '5': 9, '10': 'groupName'},
    {'1': 'format', '3': 7, '4': 1, '5': 5, '10': 'format'},
    {'1': 'content', '3': 8, '4': 1, '5': 9, '10': 'content'},
    {'1': 'time', '3': 9, '4': 1, '5': 6, '10': 'time'},
    {'1': 'memberCount', '3': 10, '4': 1, '5': 5, '10': 'memberCount'},
  ],
};

/// Descriptor for `GroupMsgPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupMsgPushDescriptor = $convert.base64Decode(
    'CgxHcm91cE1zZ1B1c2gSFAoFbXNnSWQYASABKAZSBW1zZ0lkEhIKBGZyb20YAiABKAZSBGZyb2'
    '0SIgoMZnJvbU5pY2tuYW1lGAMgASgJUgxmcm9tTmlja25hbWUSHgoKZnJvbUF2YXRhchgEIAEo'
    'CVIKZnJvbUF2YXRhchIYCgdncm91cElkGAUgASgGUgdncm91cElkEhwKCWdyb3VwTmFtZRgGIA'
    'EoCVIJZ3JvdXBOYW1lEhYKBmZvcm1hdBgHIAEoBVIGZm9ybWF0EhgKB2NvbnRlbnQYCCABKAlS'
    'B2NvbnRlbnQSEgoEdGltZRgJIAEoBlIEdGltZRIgCgttZW1iZXJDb3VudBgKIAEoBVILbWVtYm'
    'VyQ291bnQ=');

@$core.Deprecated('Use groupAckReqDescriptor instead')
const GroupAckReq$json = {
  '1': 'GroupAckReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'userId', '3': 2, '4': 1, '5': 6, '10': 'userId'},
    {'1': 'groupId', '3': 3, '4': 1, '5': 6, '10': 'groupId'},
    {'1': 'status', '3': 4, '4': 1, '5': 5, '10': 'status'},
  ],
};

/// Descriptor for `GroupAckReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupAckReqDescriptor = $convert.base64Decode(
    'CgtHcm91cEFja1JlcRIUCgVtc2dJZBgBIAEoBlIFbXNnSWQSFgoGdXNlcklkGAIgASgGUgZ1c2'
    'VySWQSGAoHZ3JvdXBJZBgDIAEoBlIHZ3JvdXBJZBIWCgZzdGF0dXMYBCABKAVSBnN0YXR1cw==');

@$core.Deprecated('Use groupWithdrawReqDescriptor instead')
const GroupWithdrawReq$json = {
  '1': 'GroupWithdrawReq',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 6, '10': 'from'},
    {'1': 'groupId', '3': 3, '4': 1, '5': 6, '10': 'groupId'},
    {'1': 'withdrawTime', '3': 4, '4': 1, '5': 6, '10': 'withdrawTime'},
  ],
};

/// Descriptor for `GroupWithdrawReq`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupWithdrawReqDescriptor = $convert.base64Decode(
    'ChBHcm91cFdpdGhkcmF3UmVxEhQKBW1zZ0lkGAEgASgGUgVtc2dJZBISCgRmcm9tGAIgASgGUg'
    'Rmcm9tEhgKB2dyb3VwSWQYAyABKAZSB2dyb3VwSWQSIgoMd2l0aGRyYXdUaW1lGAQgASgGUgx3'
    'aXRoZHJhd1RpbWU=');

@$core.Deprecated('Use groupWithdrawPushDescriptor instead')
const GroupWithdrawPush$json = {
  '1': 'GroupWithdrawPush',
  '2': [
    {'1': 'msgId', '3': 1, '4': 1, '5': 6, '10': 'msgId'},
    {'1': 'from', '3': 2, '4': 1, '5': 6, '10': 'from'},
    {'1': 'groupId', '3': 3, '4': 1, '5': 6, '10': 'groupId'},
    {'1': 'operatorNickname', '3': 4, '4': 1, '5': 9, '10': 'operatorNickname'},
    {'1': 'withdrawTime', '3': 5, '4': 1, '5': 6, '10': 'withdrawTime'},
    {'1': 'isAdmin', '3': 6, '4': 1, '5': 8, '10': 'isAdmin'},
  ],
};

/// Descriptor for `GroupWithdrawPush`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupWithdrawPushDescriptor = $convert.base64Decode(
    'ChFHcm91cFdpdGhkcmF3UHVzaBIUCgVtc2dJZBgBIAEoBlIFbXNnSWQSEgoEZnJvbRgCIAEoBl'
    'IEZnJvbRIYCgdncm91cElkGAMgASgGUgdncm91cElkEioKEG9wZXJhdG9yTmlja25hbWUYBCAB'
    'KAlSEG9wZXJhdG9yTmlja25hbWUSIgoMd2l0aGRyYXdUaW1lGAUgASgGUgx3aXRoZHJhd1RpbW'
    'USGAoHaXNBZG1pbhgGIAEoCFIHaXNBZG1pbg==');

const $core.Map<$core.String, $core.dynamic> MessageServiceBase$json = {
  '1': 'MessageService',
  '2': [
    {
      '1': 'ResponseServerAck2Client',
      '2': '.com.xzll.grpc.ServerAckPush',
      '3': '.com.xzll.grpc.WebBaseResponse',
      '4': {}
    },
    {
      '1': 'ResponseClientAck2Client',
      '2': '.com.xzll.grpc.ClientAckPush',
      '3': '.com.xzll.grpc.WebBaseResponse',
      '4': {}
    },
    {
      '1': 'SendWithdrawMsg2Client',
      '2': '.com.xzll.grpc.WithdrawPush',
      '3': '.com.xzll.grpc.WebBaseResponse',
      '4': {}
    },
    {
      '1': 'PushFriendRequest2Client',
      '2': '.com.xzll.grpc.FriendRequestPush',
      '3': '.com.xzll.grpc.WebBaseResponse',
      '4': {}
    },
    {
      '1': 'PushFriendResponse2Client',
      '2': '.com.xzll.grpc.FriendResponsePush',
      '3': '.com.xzll.grpc.WebBaseResponse',
      '4': {}
    },
    {
      '1': 'TransferC2CMsg',
      '2': '.com.xzll.grpc.ImProtoRequest',
      '3': '.com.xzll.grpc.WebBaseResponse',
      '4': {}
    },
  ],
};

@$core.Deprecated('Use messageServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    MessageServiceBase$messageJson = {
  '.com.xzll.grpc.ServerAckPush': ServerAckPush$json,
  '.com.xzll.grpc.WebBaseResponse': WebBaseResponse$json,
  '.com.xzll.grpc.ClientAckPush': ClientAckPush$json,
  '.com.xzll.grpc.WithdrawPush': WithdrawPush$json,
  '.com.xzll.grpc.FriendRequestPush': FriendRequestPush$json,
  '.com.xzll.grpc.FriendResponsePush': FriendResponsePush$json,
  '.com.xzll.grpc.ImProtoRequest': ImProtoRequest$json,
};

/// Descriptor for `MessageService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List messageServiceDescriptor = $convert.base64Decode(
    'Cg5NZXNzYWdlU2VydmljZRJaChhSZXNwb25zZVNlcnZlckFjazJDbGllbnQSHC5jb20ueHpsbC'
    '5ncnBjLlNlcnZlckFja1B1c2gaHi5jb20ueHpsbC5ncnBjLldlYkJhc2VSZXNwb25zZSIAEloK'
    'GFJlc3BvbnNlQ2xpZW50QWNrMkNsaWVudBIcLmNvbS54emxsLmdycGMuQ2xpZW50QWNrUHVzaB'
    'oeLmNvbS54emxsLmdycGMuV2ViQmFzZVJlc3BvbnNlIgASVwoWU2VuZFdpdGhkcmF3TXNnMkNs'
    'aWVudBIbLmNvbS54emxsLmdycGMuV2l0aGRyYXdQdXNoGh4uY29tLnh6bGwuZ3JwYy5XZWJCYX'
    'NlUmVzcG9uc2UiABJeChhQdXNoRnJpZW5kUmVxdWVzdDJDbGllbnQSIC5jb20ueHpsbC5ncnBj'
    'LkZyaWVuZFJlcXVlc3RQdXNoGh4uY29tLnh6bGwuZ3JwYy5XZWJCYXNlUmVzcG9uc2UiABJgCh'
    'lQdXNoRnJpZW5kUmVzcG9uc2UyQ2xpZW50EiEuY29tLnh6bGwuZ3JwYy5GcmllbmRSZXNwb25z'
    'ZVB1c2gaHi5jb20ueHpsbC5ncnBjLldlYkJhc2VSZXNwb25zZSIAElEKDlRyYW5zZmVyQzJDTX'
    'NnEh0uY29tLnh6bGwuZ3JwYy5JbVByb3RvUmVxdWVzdBoeLmNvbS54emxsLmdycGMuV2ViQmFz'
    'ZVJlc3BvbnNlIgA=');
