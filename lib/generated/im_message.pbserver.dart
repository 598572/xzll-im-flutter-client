// This is a generated file - do not edit.
//
// Generated from im_message.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'im_message.pb.dart' as $0;
import 'im_message.pbjson.dart';

export 'im_message.pb.dart';

abstract class MessageServiceBase extends $pb.GeneratedService {
  $async.Future<$0.WebBaseResponse> responseServerAck2Client(
      $pb.ServerContext ctx, $0.ServerAckPush request);
  $async.Future<$0.WebBaseResponse> responseClientAck2Client(
      $pb.ServerContext ctx, $0.ClientAckPush request);
  $async.Future<$0.WebBaseResponse> sendWithdrawMsg2Client(
      $pb.ServerContext ctx, $0.WithdrawPush request);
  $async.Future<$0.WebBaseResponse> pushFriendRequest2Client(
      $pb.ServerContext ctx, $0.FriendRequestPush request);
  $async.Future<$0.WebBaseResponse> pushFriendResponse2Client(
      $pb.ServerContext ctx, $0.FriendResponsePush request);
  $async.Future<$0.WebBaseResponse> transferC2CMsg(
      $pb.ServerContext ctx, $0.ImProtoRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ResponseServerAck2Client':
        return $0.ServerAckPush();
      case 'ResponseClientAck2Client':
        return $0.ClientAckPush();
      case 'SendWithdrawMsg2Client':
        return $0.WithdrawPush();
      case 'PushFriendRequest2Client':
        return $0.FriendRequestPush();
      case 'PushFriendResponse2Client':
        return $0.FriendResponsePush();
      case 'TransferC2CMsg':
        return $0.ImProtoRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ResponseServerAck2Client':
        return responseServerAck2Client(ctx, request as $0.ServerAckPush);
      case 'ResponseClientAck2Client':
        return responseClientAck2Client(ctx, request as $0.ClientAckPush);
      case 'SendWithdrawMsg2Client':
        return sendWithdrawMsg2Client(ctx, request as $0.WithdrawPush);
      case 'PushFriendRequest2Client':
        return pushFriendRequest2Client(ctx, request as $0.FriendRequestPush);
      case 'PushFriendResponse2Client':
        return pushFriendResponse2Client(ctx, request as $0.FriendResponsePush);
      case 'TransferC2CMsg':
        return transferC2CMsg(ctx, request as $0.ImProtoRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MessageServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => MessageServiceBase$messageJson;
}
