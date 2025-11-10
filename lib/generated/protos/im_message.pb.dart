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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'im_message.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'im_message.pbenum.dart';

/// 基础消息包装（客户端->服务端）
class ImProtoRequest extends $pb.GeneratedMessage {
  factory ImProtoRequest({
    MsgType? type,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (payload != null) result.payload = payload;
    return result;
  }

  ImProtoRequest._();

  factory ImProtoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImProtoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImProtoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aE<MsgType>(1, _omitFieldNames ? '' : 'type', enumValues: MsgType.values)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImProtoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImProtoRequest copyWith(void Function(ImProtoRequest) updates) =>
      super.copyWith((message) => updates(message as ImProtoRequest))
          as ImProtoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImProtoRequest create() => ImProtoRequest._();
  @$core.override
  ImProtoRequest createEmptyInstance() => create();
  static $pb.PbList<ImProtoRequest> createRepeated() =>
      $pb.PbList<ImProtoRequest>();
  @$core.pragma('dart2js:noInline')
  static ImProtoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImProtoRequest>(create);
  static ImProtoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MsgType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(MsgType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);
}

/// 基础响应包装（服务端->客户端）
class ImProtoResponse extends $pb.GeneratedMessage {
  factory ImProtoResponse({
    MsgType? type,
    $core.List<$core.int>? payload,
    $core.int? code,
    $core.String? msg,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (payload != null) result.payload = payload;
    if (code != null) result.code = code;
    if (msg != null) result.msg = msg;
    return result;
  }

  ImProtoResponse._();

  factory ImProtoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImProtoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImProtoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aE<MsgType>(1, _omitFieldNames ? '' : 'type', enumValues: MsgType.values)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aI(3, _omitFieldNames ? '' : 'code')
    ..aOS(4, _omitFieldNames ? '' : 'msg')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImProtoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImProtoResponse copyWith(void Function(ImProtoResponse) updates) =>
      super.copyWith((message) => updates(message as ImProtoResponse))
          as ImProtoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImProtoResponse create() => ImProtoResponse._();
  @$core.override
  ImProtoResponse createEmptyInstance() => create();
  static $pb.PbList<ImProtoResponse> createRepeated() =>
      $pb.PbList<ImProtoResponse>();
  @$core.pragma('dart2js:noInline')
  static ImProtoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImProtoResponse>(create);
  static ImProtoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MsgType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(MsgType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get code => $_getIZ(2);
  @$pb.TagNumber(3)
  set code($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCode() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get msg => $_getSZ(3);
  @$pb.TagNumber(4)
  set msg($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMsg() => $_has(3);
  @$pb.TagNumber(4)
  void clearMsg() => $_clearField(4);
}

/// C2C发送消息请求 - 上行
class C2CSendReq extends $pb.GeneratedMessage {
  factory C2CSendReq({
    $core.String? clientMsgId,
    $core.String? msgId,
    $core.String? from,
    $core.String? to,
    $core.int? format,
    $core.String? content,
    $fixnum.Int64? time,
    $core.String? chatId,
  }) {
    final result = create();
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (msgId != null) result.msgId = msgId;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (format != null) result.format = format;
    if (content != null) result.content = content;
    if (time != null) result.time = time;
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  C2CSendReq._();

  factory C2CSendReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory C2CSendReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'C2CSendReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientMsgId', protoName: 'clientMsgId')
    ..aOS(2, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(3, _omitFieldNames ? '' : 'from')
    ..aOS(4, _omitFieldNames ? '' : 'to')
    ..aI(5, _omitFieldNames ? '' : 'format')
    ..aOS(6, _omitFieldNames ? '' : 'content')
    ..aInt64(7, _omitFieldNames ? '' : 'time')
    ..aOS(8, _omitFieldNames ? '' : 'chatId', protoName: 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  C2CSendReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  C2CSendReq copyWith(void Function(C2CSendReq) updates) =>
      super.copyWith((message) => updates(message as C2CSendReq)) as C2CSendReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static C2CSendReq create() => C2CSendReq._();
  @$core.override
  C2CSendReq createEmptyInstance() => create();
  static $pb.PbList<C2CSendReq> createRepeated() => $pb.PbList<C2CSendReq>();
  @$core.pragma('dart2js:noInline')
  static C2CSendReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<C2CSendReq>(create);
  static C2CSendReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientMsgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientMsgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get msgId => $_getSZ(1);
  @$pb.TagNumber(2)
  set msgId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get from => $_getSZ(2);
  @$pb.TagNumber(3)
  set from($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrom() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get to => $_getSZ(3);
  @$pb.TagNumber(4)
  set to($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearTo() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get format => $_getIZ(4);
  @$pb.TagNumber(5)
  set format($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFormat() => $_has(4);
  @$pb.TagNumber(5)
  void clearFormat() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get content => $_getSZ(5);
  @$pb.TagNumber(6)
  set content($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasContent() => $_has(5);
  @$pb.TagNumber(6)
  void clearContent() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get time => $_getI64(6);
  @$pb.TagNumber(7)
  set time($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get chatId => $_getSZ(7);
  @$pb.TagNumber(8)
  set chatId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasChatId() => $_has(7);
  @$pb.TagNumber(8)
  void clearChatId() => $_clearField(8);
}

/// C2C消息确认请求 - 上行
class C2CAckReq extends $pb.GeneratedMessage {
  factory C2CAckReq({
    $core.String? clientMsgId,
    $core.String? msgId,
    $core.String? from,
    $core.String? to,
    $core.int? status,
    $core.String? chatId,
  }) {
    final result = create();
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (msgId != null) result.msgId = msgId;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (status != null) result.status = status;
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  C2CAckReq._();

  factory C2CAckReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory C2CAckReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'C2CAckReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientMsgId', protoName: 'clientMsgId')
    ..aOS(2, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(3, _omitFieldNames ? '' : 'from')
    ..aOS(4, _omitFieldNames ? '' : 'to')
    ..aI(5, _omitFieldNames ? '' : 'status')
    ..aOS(6, _omitFieldNames ? '' : 'chatId', protoName: 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  C2CAckReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  C2CAckReq copyWith(void Function(C2CAckReq) updates) =>
      super.copyWith((message) => updates(message as C2CAckReq)) as C2CAckReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static C2CAckReq create() => C2CAckReq._();
  @$core.override
  C2CAckReq createEmptyInstance() => create();
  static $pb.PbList<C2CAckReq> createRepeated() => $pb.PbList<C2CAckReq>();
  @$core.pragma('dart2js:noInline')
  static C2CAckReq getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<C2CAckReq>(create);
  static C2CAckReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientMsgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientMsgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get msgId => $_getSZ(1);
  @$pb.TagNumber(2)
  set msgId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get from => $_getSZ(2);
  @$pb.TagNumber(3)
  set from($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrom() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get to => $_getSZ(3);
  @$pb.TagNumber(4)
  set to($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearTo() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get status => $_getIZ(4);
  @$pb.TagNumber(5)
  set status($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get chatId => $_getSZ(5);
  @$pb.TagNumber(6)
  set chatId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasChatId() => $_has(5);
  @$pb.TagNumber(6)
  void clearChatId() => $_clearField(6);
}

/// C2C撤回消息请求 - 上行
class C2CWithdrawReq extends $pb.GeneratedMessage {
  factory C2CWithdrawReq({
    $core.String? msgId,
    $core.String? from,
    $core.String? to,
    $core.String? chatId,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  C2CWithdrawReq._();

  factory C2CWithdrawReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory C2CWithdrawReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'C2CWithdrawReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(2, _omitFieldNames ? '' : 'from')
    ..aOS(3, _omitFieldNames ? '' : 'to')
    ..aOS(4, _omitFieldNames ? '' : 'chatId', protoName: 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  C2CWithdrawReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  C2CWithdrawReq copyWith(void Function(C2CWithdrawReq) updates) =>
      super.copyWith((message) => updates(message as C2CWithdrawReq))
          as C2CWithdrawReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static C2CWithdrawReq create() => C2CWithdrawReq._();
  @$core.override
  C2CWithdrawReq createEmptyInstance() => create();
  static $pb.PbList<C2CWithdrawReq> createRepeated() =>
      $pb.PbList<C2CWithdrawReq>();
  @$core.pragma('dart2js:noInline')
  static C2CWithdrawReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<C2CWithdrawReq>(create);
  static C2CWithdrawReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set msgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get from => $_getSZ(1);
  @$pb.TagNumber(2)
  set from($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get to => $_getSZ(2);
  @$pb.TagNumber(3)
  set to($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTo() => $_has(2);
  @$pb.TagNumber(3)
  void clearTo() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get chatId => $_getSZ(3);
  @$pb.TagNumber(4)
  set chatId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChatId() => $_has(3);
  @$pb.TagNumber(4)
  void clearChatId() => $_clearField(4);
}

/// 批量获取消息ID请求 - 上行
class GetBatchMsgIdsReq extends $pb.GeneratedMessage {
  factory GetBatchMsgIdsReq({
    $core.String? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  GetBatchMsgIdsReq._();

  factory GetBatchMsgIdsReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBatchMsgIdsReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBatchMsgIdsReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'userId', protoName: 'userId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBatchMsgIdsReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBatchMsgIdsReq copyWith(void Function(GetBatchMsgIdsReq) updates) =>
      super.copyWith((message) => updates(message as GetBatchMsgIdsReq))
          as GetBatchMsgIdsReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBatchMsgIdsReq create() => GetBatchMsgIdsReq._();
  @$core.override
  GetBatchMsgIdsReq createEmptyInstance() => create();
  static $pb.PbList<GetBatchMsgIdsReq> createRepeated() =>
      $pb.PbList<GetBatchMsgIdsReq>();
  @$core.pragma('dart2js:noInline')
  static GetBatchMsgIdsReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBatchMsgIdsReq>(create);
  static GetBatchMsgIdsReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userId => $_getSZ(0);
  @$pb.TagNumber(1)
  set userId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
}

/// 服务端推送C2C消息 - 下行
class C2CMsgPush extends $pb.GeneratedMessage {
  factory C2CMsgPush({
    $core.String? clientMsgId,
    $core.String? msgId,
    $core.String? from,
    $core.String? to,
    $core.int? format,
    $core.String? content,
    $fixnum.Int64? time,
    $core.String? chatId,
  }) {
    final result = create();
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (msgId != null) result.msgId = msgId;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (format != null) result.format = format;
    if (content != null) result.content = content;
    if (time != null) result.time = time;
    if (chatId != null) result.chatId = chatId;
    return result;
  }

  C2CMsgPush._();

  factory C2CMsgPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory C2CMsgPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'C2CMsgPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'clientMsgId', protoName: 'clientMsgId')
    ..aOS(2, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(3, _omitFieldNames ? '' : 'from')
    ..aOS(4, _omitFieldNames ? '' : 'to')
    ..aI(5, _omitFieldNames ? '' : 'format')
    ..aOS(6, _omitFieldNames ? '' : 'content')
    ..aInt64(7, _omitFieldNames ? '' : 'time')
    ..aOS(8, _omitFieldNames ? '' : 'chatId', protoName: 'chatId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  C2CMsgPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  C2CMsgPush copyWith(void Function(C2CMsgPush) updates) =>
      super.copyWith((message) => updates(message as C2CMsgPush)) as C2CMsgPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static C2CMsgPush create() => C2CMsgPush._();
  @$core.override
  C2CMsgPush createEmptyInstance() => create();
  static $pb.PbList<C2CMsgPush> createRepeated() => $pb.PbList<C2CMsgPush>();
  @$core.pragma('dart2js:noInline')
  static C2CMsgPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<C2CMsgPush>(create);
  static C2CMsgPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get clientMsgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set clientMsgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClientMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClientMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get msgId => $_getSZ(1);
  @$pb.TagNumber(2)
  set msgId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get from => $_getSZ(2);
  @$pb.TagNumber(3)
  set from($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrom() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get to => $_getSZ(3);
  @$pb.TagNumber(4)
  set to($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearTo() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get format => $_getIZ(4);
  @$pb.TagNumber(5)
  set format($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFormat() => $_has(4);
  @$pb.TagNumber(5)
  void clearFormat() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get content => $_getSZ(5);
  @$pb.TagNumber(6)
  set content($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasContent() => $_has(5);
  @$pb.TagNumber(6)
  void clearContent() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get time => $_getI64(6);
  @$pb.TagNumber(7)
  set time($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get chatId => $_getSZ(7);
  @$pb.TagNumber(8)
  set chatId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasChatId() => $_has(7);
  @$pb.TagNumber(8)
  void clearChatId() => $_clearField(8);
}

/// 批量消息ID推送 - 下行
class BatchMsgIdsPush extends $pb.GeneratedMessage {
  factory BatchMsgIdsPush({
    $core.Iterable<$core.String>? msgIds,
  }) {
    final result = create();
    if (msgIds != null) result.msgIds.addAll(msgIds);
    return result;
  }

  BatchMsgIdsPush._();

  factory BatchMsgIdsPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BatchMsgIdsPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchMsgIdsPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'msgIds', protoName: 'msgIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchMsgIdsPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchMsgIdsPush copyWith(void Function(BatchMsgIdsPush) updates) =>
      super.copyWith((message) => updates(message as BatchMsgIdsPush))
          as BatchMsgIdsPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BatchMsgIdsPush create() => BatchMsgIdsPush._();
  @$core.override
  BatchMsgIdsPush createEmptyInstance() => create();
  static $pb.PbList<BatchMsgIdsPush> createRepeated() =>
      $pb.PbList<BatchMsgIdsPush>();
  @$core.pragma('dart2js:noInline')
  static BatchMsgIdsPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchMsgIdsPush>(create);
  static BatchMsgIdsPush? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get msgIds => $_getList(0);
}

/// 服务端ACK推送 - 下行（gRPC专用）
class ServerAckPush extends $pb.GeneratedMessage {
  factory ServerAckPush({
    $core.String? toUserId,
    $core.String? clientMsgId,
    $core.String? msgId,
    $core.String? chatId,
    $core.int? msgReceivedStatus,
    $core.String? ackTextDesc,
    $fixnum.Int64? receiveTime,
  }) {
    final result = create();
    if (toUserId != null) result.toUserId = toUserId;
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (msgId != null) result.msgId = msgId;
    if (chatId != null) result.chatId = chatId;
    if (msgReceivedStatus != null) result.msgReceivedStatus = msgReceivedStatus;
    if (ackTextDesc != null) result.ackTextDesc = ackTextDesc;
    if (receiveTime != null) result.receiveTime = receiveTime;
    return result;
  }

  ServerAckPush._();

  factory ServerAckPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ServerAckPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ServerAckPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'toUserId', protoName: 'toUserId')
    ..aOS(2, _omitFieldNames ? '' : 'clientMsgId', protoName: 'clientMsgId')
    ..aOS(3, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(4, _omitFieldNames ? '' : 'chatId', protoName: 'chatId')
    ..aI(5, _omitFieldNames ? '' : 'msgReceivedStatus',
        protoName: 'msgReceivedStatus')
    ..aOS(6, _omitFieldNames ? '' : 'ackTextDesc', protoName: 'ackTextDesc')
    ..aInt64(7, _omitFieldNames ? '' : 'receiveTime', protoName: 'receiveTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerAckPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ServerAckPush copyWith(void Function(ServerAckPush) updates) =>
      super.copyWith((message) => updates(message as ServerAckPush))
          as ServerAckPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ServerAckPush create() => ServerAckPush._();
  @$core.override
  ServerAckPush createEmptyInstance() => create();
  static $pb.PbList<ServerAckPush> createRepeated() =>
      $pb.PbList<ServerAckPush>();
  @$core.pragma('dart2js:noInline')
  static ServerAckPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ServerAckPush>(create);
  static ServerAckPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get toUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set toUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearToUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientMsgId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientMsgId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get msgId => $_getSZ(2);
  @$pb.TagNumber(3)
  set msgId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMsgId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMsgId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get chatId => $_getSZ(3);
  @$pb.TagNumber(4)
  set chatId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChatId() => $_has(3);
  @$pb.TagNumber(4)
  void clearChatId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get msgReceivedStatus => $_getIZ(4);
  @$pb.TagNumber(5)
  set msgReceivedStatus($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMsgReceivedStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearMsgReceivedStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get ackTextDesc => $_getSZ(5);
  @$pb.TagNumber(6)
  set ackTextDesc($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAckTextDesc() => $_has(5);
  @$pb.TagNumber(6)
  void clearAckTextDesc() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get receiveTime => $_getI64(6);
  @$pb.TagNumber(7)
  set receiveTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReceiveTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearReceiveTime() => $_clearField(7);
}

/// 客户端ACK推送 - 下行（gRPC专用）
class ClientAckPush extends $pb.GeneratedMessage {
  factory ClientAckPush({
    $core.String? toUserId,
    $core.String? clientMsgId,
    $core.String? msgId,
    $core.String? chatId,
    $core.int? msgReceivedStatus,
    $core.String? ackTextDesc,
    $fixnum.Int64? receiveTime,
  }) {
    final result = create();
    if (toUserId != null) result.toUserId = toUserId;
    if (clientMsgId != null) result.clientMsgId = clientMsgId;
    if (msgId != null) result.msgId = msgId;
    if (chatId != null) result.chatId = chatId;
    if (msgReceivedStatus != null) result.msgReceivedStatus = msgReceivedStatus;
    if (ackTextDesc != null) result.ackTextDesc = ackTextDesc;
    if (receiveTime != null) result.receiveTime = receiveTime;
    return result;
  }

  ClientAckPush._();

  factory ClientAckPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientAckPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClientAckPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'toUserId', protoName: 'toUserId')
    ..aOS(2, _omitFieldNames ? '' : 'clientMsgId', protoName: 'clientMsgId')
    ..aOS(3, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(4, _omitFieldNames ? '' : 'chatId', protoName: 'chatId')
    ..aI(5, _omitFieldNames ? '' : 'msgReceivedStatus',
        protoName: 'msgReceivedStatus')
    ..aOS(6, _omitFieldNames ? '' : 'ackTextDesc', protoName: 'ackTextDesc')
    ..aInt64(7, _omitFieldNames ? '' : 'receiveTime', protoName: 'receiveTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientAckPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientAckPush copyWith(void Function(ClientAckPush) updates) =>
      super.copyWith((message) => updates(message as ClientAckPush))
          as ClientAckPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientAckPush create() => ClientAckPush._();
  @$core.override
  ClientAckPush createEmptyInstance() => create();
  static $pb.PbList<ClientAckPush> createRepeated() =>
      $pb.PbList<ClientAckPush>();
  @$core.pragma('dart2js:noInline')
  static ClientAckPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClientAckPush>(create);
  static ClientAckPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get toUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set toUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearToUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientMsgId => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientMsgId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClientMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get msgId => $_getSZ(2);
  @$pb.TagNumber(3)
  set msgId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMsgId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMsgId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get chatId => $_getSZ(3);
  @$pb.TagNumber(4)
  set chatId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChatId() => $_has(3);
  @$pb.TagNumber(4)
  void clearChatId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get msgReceivedStatus => $_getIZ(4);
  @$pb.TagNumber(5)
  set msgReceivedStatus($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMsgReceivedStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearMsgReceivedStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get ackTextDesc => $_getSZ(5);
  @$pb.TagNumber(6)
  set ackTextDesc($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAckTextDesc() => $_has(5);
  @$pb.TagNumber(6)
  void clearAckTextDesc() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get receiveTime => $_getI64(6);
  @$pb.TagNumber(7)
  set receiveTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReceiveTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearReceiveTime() => $_clearField(7);
}

/// 撤回消息推送 - 下行（gRPC专用）
class WithdrawPush extends $pb.GeneratedMessage {
  factory WithdrawPush({
    $core.String? toUserId,
    $core.String? msgId,
    $core.String? chatId,
    $core.String? fromUserId,
  }) {
    final result = create();
    if (toUserId != null) result.toUserId = toUserId;
    if (msgId != null) result.msgId = msgId;
    if (chatId != null) result.chatId = chatId;
    if (fromUserId != null) result.fromUserId = fromUserId;
    return result;
  }

  WithdrawPush._();

  factory WithdrawPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WithdrawPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WithdrawPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'toUserId', protoName: 'toUserId')
    ..aOS(2, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(3, _omitFieldNames ? '' : 'chatId', protoName: 'chatId')
    ..aOS(4, _omitFieldNames ? '' : 'fromUserId', protoName: 'fromUserId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawPush copyWith(void Function(WithdrawPush) updates) =>
      super.copyWith((message) => updates(message as WithdrawPush))
          as WithdrawPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawPush create() => WithdrawPush._();
  @$core.override
  WithdrawPush createEmptyInstance() => create();
  static $pb.PbList<WithdrawPush> createRepeated() =>
      $pb.PbList<WithdrawPush>();
  @$core.pragma('dart2js:noInline')
  static WithdrawPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawPush>(create);
  static WithdrawPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get toUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set toUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearToUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get msgId => $_getSZ(1);
  @$pb.TagNumber(2)
  set msgId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMsgId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMsgId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get chatId => $_getSZ(2);
  @$pb.TagNumber(3)
  set chatId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasChatId() => $_has(2);
  @$pb.TagNumber(3)
  void clearChatId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fromUserId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fromUserId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFromUserId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFromUserId() => $_clearField(4);
}

/// 好友请求推送 - 下行（gRPC专用）
class FriendRequestPush extends $pb.GeneratedMessage {
  factory FriendRequestPush({
    $core.String? toUserId,
    $core.String? requestId,
    $core.String? fromUserId,
    $core.String? fromUserName,
    $core.String? fromUserAvatar,
    $core.String? requestMessage,
    $core.int? status,
    $fixnum.Int64? createTime,
    $core.String? pushTitle,
    $core.String? pushContent,
  }) {
    final result = create();
    if (toUserId != null) result.toUserId = toUserId;
    if (requestId != null) result.requestId = requestId;
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (fromUserName != null) result.fromUserName = fromUserName;
    if (fromUserAvatar != null) result.fromUserAvatar = fromUserAvatar;
    if (requestMessage != null) result.requestMessage = requestMessage;
    if (status != null) result.status = status;
    if (createTime != null) result.createTime = createTime;
    if (pushTitle != null) result.pushTitle = pushTitle;
    if (pushContent != null) result.pushContent = pushContent;
    return result;
  }

  FriendRequestPush._();

  factory FriendRequestPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FriendRequestPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FriendRequestPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'toUserId', protoName: 'toUserId')
    ..aOS(2, _omitFieldNames ? '' : 'requestId', protoName: 'requestId')
    ..aOS(3, _omitFieldNames ? '' : 'fromUserId', protoName: 'fromUserId')
    ..aOS(4, _omitFieldNames ? '' : 'fromUserName', protoName: 'fromUserName')
    ..aOS(5, _omitFieldNames ? '' : 'fromUserAvatar',
        protoName: 'fromUserAvatar')
    ..aOS(6, _omitFieldNames ? '' : 'requestMessage',
        protoName: 'requestMessage')
    ..aI(7, _omitFieldNames ? '' : 'status')
    ..aInt64(8, _omitFieldNames ? '' : 'createTime', protoName: 'createTime')
    ..aOS(9, _omitFieldNames ? '' : 'pushTitle', protoName: 'pushTitle')
    ..aOS(10, _omitFieldNames ? '' : 'pushContent', protoName: 'pushContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendRequestPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendRequestPush copyWith(void Function(FriendRequestPush) updates) =>
      super.copyWith((message) => updates(message as FriendRequestPush))
          as FriendRequestPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendRequestPush create() => FriendRequestPush._();
  @$core.override
  FriendRequestPush createEmptyInstance() => create();
  static $pb.PbList<FriendRequestPush> createRepeated() =>
      $pb.PbList<FriendRequestPush>();
  @$core.pragma('dart2js:noInline')
  static FriendRequestPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FriendRequestPush>(create);
  static FriendRequestPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get toUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set toUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearToUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get requestId => $_getSZ(1);
  @$pb.TagNumber(2)
  set requestId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fromUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fromUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fromUserName => $_getSZ(3);
  @$pb.TagNumber(4)
  set fromUserName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFromUserName() => $_has(3);
  @$pb.TagNumber(4)
  void clearFromUserName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fromUserAvatar => $_getSZ(4);
  @$pb.TagNumber(5)
  set fromUserAvatar($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFromUserAvatar() => $_has(4);
  @$pb.TagNumber(5)
  void clearFromUserAvatar() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get requestMessage => $_getSZ(5);
  @$pb.TagNumber(6)
  set requestMessage($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRequestMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearRequestMessage() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get status => $_getIZ(6);
  @$pb.TagNumber(7)
  set status($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get createTime => $_getI64(7);
  @$pb.TagNumber(8)
  set createTime($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreateTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreateTime() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get pushTitle => $_getSZ(8);
  @$pb.TagNumber(9)
  set pushTitle($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPushTitle() => $_has(8);
  @$pb.TagNumber(9)
  void clearPushTitle() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get pushContent => $_getSZ(9);
  @$pb.TagNumber(10)
  set pushContent($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPushContent() => $_has(9);
  @$pb.TagNumber(10)
  void clearPushContent() => $_clearField(10);
}

/// 好友响应推送 - 下行（gRPC专用，用于通知申请人结果）
class FriendResponsePush extends $pb.GeneratedMessage {
  factory FriendResponsePush({
    $core.String? toUserId,
    $core.String? requestId,
    $core.String? fromUserId,
    $core.String? fromUserName,
    $core.String? fromUserAvatar,
    $core.int? status,
    $fixnum.Int64? responseTime,
    $core.String? pushTitle,
    $core.String? pushContent,
  }) {
    final result = create();
    if (toUserId != null) result.toUserId = toUserId;
    if (requestId != null) result.requestId = requestId;
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (fromUserName != null) result.fromUserName = fromUserName;
    if (fromUserAvatar != null) result.fromUserAvatar = fromUserAvatar;
    if (status != null) result.status = status;
    if (responseTime != null) result.responseTime = responseTime;
    if (pushTitle != null) result.pushTitle = pushTitle;
    if (pushContent != null) result.pushContent = pushContent;
    return result;
  }

  FriendResponsePush._();

  factory FriendResponsePush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FriendResponsePush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FriendResponsePush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'toUserId', protoName: 'toUserId')
    ..aOS(2, _omitFieldNames ? '' : 'requestId', protoName: 'requestId')
    ..aOS(3, _omitFieldNames ? '' : 'fromUserId', protoName: 'fromUserId')
    ..aOS(4, _omitFieldNames ? '' : 'fromUserName', protoName: 'fromUserName')
    ..aOS(5, _omitFieldNames ? '' : 'fromUserAvatar',
        protoName: 'fromUserAvatar')
    ..aI(6, _omitFieldNames ? '' : 'status')
    ..aInt64(7, _omitFieldNames ? '' : 'responseTime',
        protoName: 'responseTime')
    ..aOS(8, _omitFieldNames ? '' : 'pushTitle', protoName: 'pushTitle')
    ..aOS(9, _omitFieldNames ? '' : 'pushContent', protoName: 'pushContent')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendResponsePush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FriendResponsePush copyWith(void Function(FriendResponsePush) updates) =>
      super.copyWith((message) => updates(message as FriendResponsePush))
          as FriendResponsePush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FriendResponsePush create() => FriendResponsePush._();
  @$core.override
  FriendResponsePush createEmptyInstance() => create();
  static $pb.PbList<FriendResponsePush> createRepeated() =>
      $pb.PbList<FriendResponsePush>();
  @$core.pragma('dart2js:noInline')
  static FriendResponsePush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FriendResponsePush>(create);
  static FriendResponsePush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get toUserId => $_getSZ(0);
  @$pb.TagNumber(1)
  set toUserId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearToUserId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get requestId => $_getSZ(1);
  @$pb.TagNumber(2)
  set requestId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fromUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fromUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fromUserName => $_getSZ(3);
  @$pb.TagNumber(4)
  set fromUserName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFromUserName() => $_has(3);
  @$pb.TagNumber(4)
  void clearFromUserName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fromUserAvatar => $_getSZ(4);
  @$pb.TagNumber(5)
  set fromUserAvatar($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFromUserAvatar() => $_has(4);
  @$pb.TagNumber(5)
  void clearFromUserAvatar() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get status => $_getIZ(5);
  @$pb.TagNumber(6)
  set status($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get responseTime => $_getI64(6);
  @$pb.TagNumber(7)
  set responseTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasResponseTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearResponseTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get pushTitle => $_getSZ(7);
  @$pb.TagNumber(8)
  set pushTitle($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPushTitle() => $_has(7);
  @$pb.TagNumber(8)
  void clearPushTitle() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get pushContent => $_getSZ(8);
  @$pb.TagNumber(9)
  set pushContent($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPushContent() => $_has(8);
  @$pb.TagNumber(9)
  void clearPushContent() => $_clearField(9);
}

/// 群聊发送消息请求 - 上行
class GroupSendReq extends $pb.GeneratedMessage {
  factory GroupSendReq({
    $core.String? msgId,
    $core.String? from,
    $core.String? groupId,
    $core.int? format,
    $core.String? content,
    $fixnum.Int64? time,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (from != null) result.from = from;
    if (groupId != null) result.groupId = groupId;
    if (format != null) result.format = format;
    if (content != null) result.content = content;
    if (time != null) result.time = time;
    return result;
  }

  GroupSendReq._();

  factory GroupSendReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupSendReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupSendReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(2, _omitFieldNames ? '' : 'from')
    ..aOS(3, _omitFieldNames ? '' : 'groupId', protoName: 'groupId')
    ..aI(4, _omitFieldNames ? '' : 'format')
    ..aOS(5, _omitFieldNames ? '' : 'content')
    ..aInt64(6, _omitFieldNames ? '' : 'time')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupSendReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupSendReq copyWith(void Function(GroupSendReq) updates) =>
      super.copyWith((message) => updates(message as GroupSendReq))
          as GroupSendReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupSendReq create() => GroupSendReq._();
  @$core.override
  GroupSendReq createEmptyInstance() => create();
  static $pb.PbList<GroupSendReq> createRepeated() =>
      $pb.PbList<GroupSendReq>();
  @$core.pragma('dart2js:noInline')
  static GroupSendReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupSendReq>(create);
  static GroupSendReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set msgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get from => $_getSZ(1);
  @$pb.TagNumber(2)
  set from($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get groupId => $_getSZ(2);
  @$pb.TagNumber(3)
  set groupId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupId() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get format => $_getIZ(3);
  @$pb.TagNumber(4)
  set format($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFormat() => $_has(3);
  @$pb.TagNumber(4)
  void clearFormat() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get content => $_getSZ(4);
  @$pb.TagNumber(5)
  set content($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasContent() => $_has(4);
  @$pb.TagNumber(5)
  void clearContent() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get time => $_getI64(5);
  @$pb.TagNumber(6)
  set time($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearTime() => $_clearField(6);
}

/// 群聊消息推送 - 下行
class GroupMsgPush extends $pb.GeneratedMessage {
  factory GroupMsgPush({
    $core.String? msgId,
    $core.String? from,
    $core.String? fromNickname,
    $core.String? fromAvatar,
    $core.String? groupId,
    $core.String? groupName,
    $core.int? format,
    $core.String? content,
    $fixnum.Int64? time,
    $core.int? memberCount,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (from != null) result.from = from;
    if (fromNickname != null) result.fromNickname = fromNickname;
    if (fromAvatar != null) result.fromAvatar = fromAvatar;
    if (groupId != null) result.groupId = groupId;
    if (groupName != null) result.groupName = groupName;
    if (format != null) result.format = format;
    if (content != null) result.content = content;
    if (time != null) result.time = time;
    if (memberCount != null) result.memberCount = memberCount;
    return result;
  }

  GroupMsgPush._();

  factory GroupMsgPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupMsgPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupMsgPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(2, _omitFieldNames ? '' : 'from')
    ..aOS(3, _omitFieldNames ? '' : 'fromNickname', protoName: 'fromNickname')
    ..aOS(4, _omitFieldNames ? '' : 'fromAvatar', protoName: 'fromAvatar')
    ..aOS(5, _omitFieldNames ? '' : 'groupId', protoName: 'groupId')
    ..aOS(6, _omitFieldNames ? '' : 'groupName', protoName: 'groupName')
    ..aI(7, _omitFieldNames ? '' : 'format')
    ..aOS(8, _omitFieldNames ? '' : 'content')
    ..aInt64(9, _omitFieldNames ? '' : 'time')
    ..aI(10, _omitFieldNames ? '' : 'memberCount', protoName: 'memberCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMsgPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupMsgPush copyWith(void Function(GroupMsgPush) updates) =>
      super.copyWith((message) => updates(message as GroupMsgPush))
          as GroupMsgPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupMsgPush create() => GroupMsgPush._();
  @$core.override
  GroupMsgPush createEmptyInstance() => create();
  static $pb.PbList<GroupMsgPush> createRepeated() =>
      $pb.PbList<GroupMsgPush>();
  @$core.pragma('dart2js:noInline')
  static GroupMsgPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupMsgPush>(create);
  static GroupMsgPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set msgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get from => $_getSZ(1);
  @$pb.TagNumber(2)
  set from($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fromNickname => $_getSZ(2);
  @$pb.TagNumber(3)
  set fromNickname($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromNickname() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromNickname() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fromAvatar => $_getSZ(3);
  @$pb.TagNumber(4)
  set fromAvatar($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFromAvatar() => $_has(3);
  @$pb.TagNumber(4)
  void clearFromAvatar() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get groupId => $_getSZ(4);
  @$pb.TagNumber(5)
  set groupId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGroupId() => $_has(4);
  @$pb.TagNumber(5)
  void clearGroupId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get groupName => $_getSZ(5);
  @$pb.TagNumber(6)
  set groupName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGroupName() => $_has(5);
  @$pb.TagNumber(6)
  void clearGroupName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get format => $_getIZ(6);
  @$pb.TagNumber(7)
  set format($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFormat() => $_has(6);
  @$pb.TagNumber(7)
  void clearFormat() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get content => $_getSZ(7);
  @$pb.TagNumber(8)
  set content($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasContent() => $_has(7);
  @$pb.TagNumber(8)
  void clearContent() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get time => $_getI64(8);
  @$pb.TagNumber(9)
  set time($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearTime() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get memberCount => $_getIZ(9);
  @$pb.TagNumber(10)
  set memberCount($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMemberCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearMemberCount() => $_clearField(10);
}

/// 群聊消息确认请求 - 上行
class GroupAckReq extends $pb.GeneratedMessage {
  factory GroupAckReq({
    $core.String? msgId,
    $core.String? userId,
    $core.String? groupId,
    $core.int? status,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (userId != null) result.userId = userId;
    if (groupId != null) result.groupId = groupId;
    if (status != null) result.status = status;
    return result;
  }

  GroupAckReq._();

  factory GroupAckReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupAckReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupAckReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(2, _omitFieldNames ? '' : 'userId', protoName: 'userId')
    ..aOS(3, _omitFieldNames ? '' : 'groupId', protoName: 'groupId')
    ..aI(4, _omitFieldNames ? '' : 'status')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupAckReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupAckReq copyWith(void Function(GroupAckReq) updates) =>
      super.copyWith((message) => updates(message as GroupAckReq))
          as GroupAckReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupAckReq create() => GroupAckReq._();
  @$core.override
  GroupAckReq createEmptyInstance() => create();
  static $pb.PbList<GroupAckReq> createRepeated() => $pb.PbList<GroupAckReq>();
  @$core.pragma('dart2js:noInline')
  static GroupAckReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupAckReq>(create);
  static GroupAckReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set msgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get groupId => $_getSZ(2);
  @$pb.TagNumber(3)
  set groupId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupId() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get status => $_getIZ(3);
  @$pb.TagNumber(4)
  set status($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);
}

/// 群聊撤回消息请求 - 上行
class GroupWithdrawReq extends $pb.GeneratedMessage {
  factory GroupWithdrawReq({
    $core.String? msgId,
    $core.String? from,
    $core.String? groupId,
    $fixnum.Int64? withdrawTime,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (from != null) result.from = from;
    if (groupId != null) result.groupId = groupId;
    if (withdrawTime != null) result.withdrawTime = withdrawTime;
    return result;
  }

  GroupWithdrawReq._();

  factory GroupWithdrawReq.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupWithdrawReq.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupWithdrawReq',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(2, _omitFieldNames ? '' : 'from')
    ..aOS(3, _omitFieldNames ? '' : 'groupId', protoName: 'groupId')
    ..aInt64(4, _omitFieldNames ? '' : 'withdrawTime',
        protoName: 'withdrawTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupWithdrawReq clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupWithdrawReq copyWith(void Function(GroupWithdrawReq) updates) =>
      super.copyWith((message) => updates(message as GroupWithdrawReq))
          as GroupWithdrawReq;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupWithdrawReq create() => GroupWithdrawReq._();
  @$core.override
  GroupWithdrawReq createEmptyInstance() => create();
  static $pb.PbList<GroupWithdrawReq> createRepeated() =>
      $pb.PbList<GroupWithdrawReq>();
  @$core.pragma('dart2js:noInline')
  static GroupWithdrawReq getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupWithdrawReq>(create);
  static GroupWithdrawReq? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set msgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get from => $_getSZ(1);
  @$pb.TagNumber(2)
  set from($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get groupId => $_getSZ(2);
  @$pb.TagNumber(3)
  set groupId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupId() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get withdrawTime => $_getI64(3);
  @$pb.TagNumber(4)
  set withdrawTime($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWithdrawTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearWithdrawTime() => $_clearField(4);
}

/// 群聊撤回消息推送 - 下行
class GroupWithdrawPush extends $pb.GeneratedMessage {
  factory GroupWithdrawPush({
    $core.String? msgId,
    $core.String? from,
    $core.String? groupId,
    $core.String? operatorNickname,
    $fixnum.Int64? withdrawTime,
    $core.bool? isAdmin,
  }) {
    final result = create();
    if (msgId != null) result.msgId = msgId;
    if (from != null) result.from = from;
    if (groupId != null) result.groupId = groupId;
    if (operatorNickname != null) result.operatorNickname = operatorNickname;
    if (withdrawTime != null) result.withdrawTime = withdrawTime;
    if (isAdmin != null) result.isAdmin = isAdmin;
    return result;
  }

  GroupWithdrawPush._();

  factory GroupWithdrawPush.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GroupWithdrawPush.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GroupWithdrawPush',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'xzll.im'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'msgId', protoName: 'msgId')
    ..aOS(2, _omitFieldNames ? '' : 'from')
    ..aOS(3, _omitFieldNames ? '' : 'groupId', protoName: 'groupId')
    ..aOS(4, _omitFieldNames ? '' : 'operatorNickname',
        protoName: 'operatorNickname')
    ..aInt64(5, _omitFieldNames ? '' : 'withdrawTime',
        protoName: 'withdrawTime')
    ..aOB(6, _omitFieldNames ? '' : 'isAdmin', protoName: 'isAdmin')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupWithdrawPush clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupWithdrawPush copyWith(void Function(GroupWithdrawPush) updates) =>
      super.copyWith((message) => updates(message as GroupWithdrawPush))
          as GroupWithdrawPush;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupWithdrawPush create() => GroupWithdrawPush._();
  @$core.override
  GroupWithdrawPush createEmptyInstance() => create();
  static $pb.PbList<GroupWithdrawPush> createRepeated() =>
      $pb.PbList<GroupWithdrawPush>();
  @$core.pragma('dart2js:noInline')
  static GroupWithdrawPush getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GroupWithdrawPush>(create);
  static GroupWithdrawPush? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get msgId => $_getSZ(0);
  @$pb.TagNumber(1)
  set msgId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMsgId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMsgId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get from => $_getSZ(1);
  @$pb.TagNumber(2)
  set from($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get groupId => $_getSZ(2);
  @$pb.TagNumber(3)
  set groupId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGroupId() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroupId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get operatorNickname => $_getSZ(3);
  @$pb.TagNumber(4)
  set operatorNickname($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOperatorNickname() => $_has(3);
  @$pb.TagNumber(4)
  void clearOperatorNickname() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get withdrawTime => $_getI64(4);
  @$pb.TagNumber(5)
  set withdrawTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWithdrawTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearWithdrawTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isAdmin => $_getBF(5);
  @$pb.TagNumber(6)
  set isAdmin($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsAdmin() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsAdmin() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
