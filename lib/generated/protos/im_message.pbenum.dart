// This is a generated file - do not edit.
//
// Generated from protos/im_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// 消息类型枚举
class MsgType extends $pb.ProtobufEnum {
  static const MsgType MSG_TYPE_UNKNOWN =
      MsgType._(0, _omitEnumNames ? '' : 'MSG_TYPE_UNKNOWN');

  /// ========== 单聊相关 ==========
  static const MsgType C2C_SEND =
      MsgType._(1, _omitEnumNames ? '' : 'C2C_SEND');
  static const MsgType C2C_ACK = MsgType._(2, _omitEnumNames ? '' : 'C2C_ACK');
  static const MsgType C2C_WITHDRAW =
      MsgType._(3, _omitEnumNames ? '' : 'C2C_WITHDRAW');
  static const MsgType C2C_MSG_PUSH =
      MsgType._(5, _omitEnumNames ? '' : 'C2C_MSG_PUSH');

  /// ========== 群聊相关（预留，暂未实现） ==========
  static const MsgType GROUP_SEND =
      MsgType._(7, _omitEnumNames ? '' : 'GROUP_SEND');
  static const MsgType GROUP_MSG_PUSH =
      MsgType._(8, _omitEnumNames ? '' : 'GROUP_MSG_PUSH');
  static const MsgType GROUP_ACK =
      MsgType._(9, _omitEnumNames ? '' : 'GROUP_ACK');
  static const MsgType GROUP_WITHDRAW =
      MsgType._(10, _omitEnumNames ? '' : 'GROUP_WITHDRAW');

  /// ========== 好友相关 ==========
  static const MsgType FRIEND_REQUEST =
      MsgType._(11, _omitEnumNames ? '' : 'FRIEND_REQUEST');
  static const MsgType FRIEND_RESPONSE =
      MsgType._(12, _omitEnumNames ? '' : 'FRIEND_RESPONSE');

  /// ========== 通用功能 ==========
  static const MsgType GET_BATCH_MSG_IDS =
      MsgType._(4, _omitEnumNames ? '' : 'GET_BATCH_MSG_IDS');
  static const MsgType PUSH_BATCH_MSG_IDS =
      MsgType._(6, _omitEnumNames ? '' : 'PUSH_BATCH_MSG_IDS');

  static const $core.List<MsgType> values = <MsgType>[
    MSG_TYPE_UNKNOWN,
    C2C_SEND,
    C2C_ACK,
    C2C_WITHDRAW,
    C2C_MSG_PUSH,
    GROUP_SEND,
    GROUP_MSG_PUSH,
    GROUP_ACK,
    GROUP_WITHDRAW,
    FRIEND_REQUEST,
    FRIEND_RESPONSE,
    GET_BATCH_MSG_IDS,
    PUSH_BATCH_MSG_IDS,
  ];

  static final $core.List<MsgType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 12);
  static MsgType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MsgType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
