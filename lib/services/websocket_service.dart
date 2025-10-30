import 'dart:async';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';
import 'package:get/get.dart';
import "package:web_socket_channel/io.dart";
import 'package:xzll_im_flutter_client/constant/app_config.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/app_tools.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/generated/im_message.pb.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';
import 'package:xzll_im_flutter_client/models/domain/message_status_changed_model.dart';
import 'package:xzll_im_flutter_client/models/enum/connectivity_status.dart';
import 'package:xzll_im_flutter_client/models/enum/message_status.dart';
import 'package:xzll_im_flutter_client/models/enum/message_type.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';

/// WebSocket服务类 - Protobuf版本
class WebSocketService extends GetxService {
  IOWebSocketChannel? _channel;

  final AppData appData = Get.find<AppData>();

  String get _currentUserId => appData.user.value.id;

  late int retryCount = AppConfig.webSocketRetryCount;

  // 本地消息ID缓存
  final List<String> _msgIds = [];
  bool _isGettingMsgIds = false;

  @override
  void onInit() {
    super.onInit();
    AppEvent.networkStatus.stream.listen(_onNetworkStatusChanged);
  }

  ///监听网络状态的变化
  void _onNetworkStatusChanged(ConnectivityStatus status) async {
    debug(status.name);
    switch (status) {
      case ConnectivityStatus.normal:
        retryWebSocket();
        break;
      case ConnectivityStatus.none:
        {
          if (_channel != null) {
            _channel!.sink.close();
          }
          break;
        }
    }
  }

  ///初始化WebSocket
  Future<void> initWebSocket() async {
    if (appData.token.isEmpty || appData.user.value.id.isEmpty || appData.refreshToken.isEmpty) {
      waring("⚠️ 用户未登录，无法初始化WebSocket");
      return;
    }
    final wsUrl = AppConfig.getWebSocketUrl(_currentUserId);
    final headers = {
      'Connection': 'Upgrade',
      'Upgrade': 'websocket',
      'token': appData.token.value,
      'uid': _currentUserId,
    };
    try {
      AppEvent.webSocketStatus.add(WebSocketStatus.connecting);
      _channel = IOWebSocketChannel.connect(wsUrl, headers: headers);
      AppEvent.webSocketStatus.add(WebSocketStatus.connected);
      retryCount = AppConfig.webSocketRetryCount;
      _channel?.stream.listen(_onData, onError: _onError, onDone: _onDone);
      
      // 连接成功后立即获取消息ID
      info("🔗 WebSocket连接成功，500ms后开始获取消息ID");
      await Future.delayed(Duration(milliseconds: 500));
      getMsgIdsFromServer();
    } catch (e) {
      error("❌ WebSocket连接失败: $e");
      AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
    }
  }

  ///重试连接
  Future<void> retryWebSocket() async {
    if (retryCount < 1) {
      return;
    }
    retryCount--;

    if (AppEvent.webSocketStatus.value != WebSocketStatus.connected) {
      AppEvent.webSocketStatus.add(WebSocketStatus.reconnecting);
      if (appData.token.isEmpty || appData.refreshToken.isEmpty) {
        return;
      }
      if (_channel != null) {
        await _channel!.sink.close();
      }
      await initWebSocket();
    }
  }

  void _onDone() async {
    AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
    waring("🔌 WebSocket连接已关闭");
    await retryWebSocket();
  }

  void _onError(Object e, StackTrace stackTrace) {
    AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
    error("❌ WebSocket错误: $e  $stackTrace");
  }

  // 从服务器获取消息ID
  Future<void> getMsgIdsFromServer() async {
    info("📞 开始获取消息ID - WebSocket状态: ${_channel != null ? '已连接' : '未连接'}");
    
    if (_isGettingMsgIds) {
      info("⏳ 正在获取消息ID中...");
      return;
    }

    if (_channel == null) {
      error("❌ WebSocket未连接，无法获取消息ID");
      return;
    }

    try {
      _isGettingMsgIds = true;
      info("🔄 设置获取状态为true，当前用户ID: $_currentUserId");
      
      // 构建获取消息ID请求
      GetBatchMsgIdsReq getBatchMsgIdsReq = GetBatchMsgIdsReq(
        userId: _currentUserId,
      );

      // 包装为 ImProtoRequest
      ImProtoRequest protoRequest = ImProtoRequest(
        type: MsgType.GET_BATCH_MSG_IDS,
        payload: getBatchMsgIdsReq.writeToBuffer(),
      );

      // 发送 Protobuf 二进制消息
      Uint8List bytes = protoRequest.writeToBuffer();
      _channel!.sink.add(bytes);
      info("📤 发送获取消息ID请求成功 - 请求类型: ${protoRequest.type.name}");
    } catch (e) {
      error("❌ 获取消息ID失败: $e");
      _isGettingMsgIds = false;
    }
  }

  // 处理接收到的消息
  void _onData(dynamic message) {
    try {
      if (message is! Uint8List && message is! List<int>) {
        info("⚠️ 收到非二进制消息，跳过: ${message.runtimeType}");
        return;
      }

      // 解析 ImProtoResponse
      Uint8List bytes = message is Uint8List ? message : Uint8List.fromList(message);
      ImProtoResponse protoResponse = ImProtoResponse.fromBuffer(bytes);

      info("📨 收到 Protobuf 消息 - 类型: ${protoResponse.type.name}, 响应码: ${protoResponse.code}, msg: ${protoResponse.msg}");

      // 根据消息类型处理
      _handleProtoMessage(protoResponse);
    } catch (e, stackTrace) {
      error("❌ 处理消息失败: $e\n$stackTrace");
    }
  }

  /// 处理 Protobuf 消息
  void _handleProtoMessage(ImProtoResponse protoResponse) {
    try {
      switch (protoResponse.type) {
        case MsgType.C2C_MSG_PUSH:
          // 处理服务端推送的单聊消息
          _handlePushMsg(protoResponse);
          break;

        case MsgType.PUSH_BATCH_MSG_IDS:
          // 处理批量消息ID
          _handleBatchMsgIds(protoResponse);
          break;

        case MsgType.C2C_ACK:
          // 处理ACK消息（服务端推送的ACK）
          _handleAckMessage(protoResponse);
          break;

        case MsgType.C2C_WITHDRAW:
          // 处理撤回通知
          _handleWithdrawMessage(protoResponse);
          break;

        case MsgType.FRIEND_REQUEST:
          // 处理好友请求
          _handleFriendRequest(protoResponse);
          break;

        case MsgType.FRIEND_RESPONSE:
          // 处理好友响应
          _handleFriendResponse(protoResponse);
          break;

        default:
          info("❓ 未知消息类型: ${protoResponse.type.name}");
          break;
      }
    } catch (e, stackTrace) {
      error("❌ 处理 Protobuf 消息异常: $e\n$stackTrace");
    }
  }

  /// 处理推送消息（单聊消息）
  void _handlePushMsg(ImProtoResponse protoResponse) {
    try {
      C2CMsgPush pushMsg = C2CMsgPush.fromBuffer(protoResponse.payload);

      info("============================================");
      info("【收到单聊消息】");
      info("  消息ID: ${pushMsg.msgId}");
      info("  发送人: ${pushMsg.from}");
      info("  接收人: ${pushMsg.to}");
      info("  消息格式: ${pushMsg.format}");
      info("  消息内容: ${pushMsg.content}");
      info("  时间戳: ${pushMsg.time}");
      info("  会话ID: ${pushMsg.chatId}");
      info("============================================");

      // 转换为ChatMessage
      ChatMessage message = ChatMessage(
        msgId: pushMsg.msgId,
        fromUserId: pushMsg.from,
        toUserId: pushMsg.to,
        content: pushMsg.content,
        timestamp: DateTime.fromMillisecondsSinceEpoch(pushMsg.time.toInt()),
        type: pushMsg.format,
        chatId: pushMsg.chatId,
        status: MessageStatus.unRead, // 接收到的消息显示为未读状态
      );

      AppEvent.onMessageReceived.add(message);

      // 自动发送接收确认
      sendReceivedAck(pushMsg.msgId, pushMsg.from, pushMsg.to, pushMsg.chatId);
      _updateConversationOnNewMessage(message);
    } catch (e, stackTrace) {
      error("❌ 解析 C2CMsgPush 失败: $e\n$stackTrace");
    }
  }

  /// 处理批量消息ID
  void _handleBatchMsgIds(ImProtoResponse protoResponse) {
    try {
      info("📥 开始处理批量消息ID响应");
      BatchMsgIdsPush resp = BatchMsgIdsPush.fromBuffer(protoResponse.payload);
      List<String> msgIdList = resp.msgIds;

      info("🆔 获取到消息ID，数量: ${msgIdList.length}");
      if (msgIdList.isNotEmpty) {
        info("📝 消息ID列表前5个: ${msgIdList.take(5).toList()}");
      }

      if (msgIdList.isNotEmpty) {
        int oldCount = _msgIds.length;
        _msgIds.addAll(msgIdList);
        info("✅ 消息ID已添加到本地缓存，原数量: $oldCount, 新增: ${msgIdList.length}, 总数量: ${_msgIds.length}");
        AppEvent.onMsgIdsReceived.add(msgIdList);
      } else {
        waring("⚠️ 服务器返回的消息ID列表为空");
      }

      _isGettingMsgIds = false;
      info("🔓 消息ID获取完成，已释放获取锁");
    } catch (e, stackTrace) {
      error("❌ 解析 BatchMsgIdsPush 失败: $e\n$stackTrace");
      _isGettingMsgIds = false;
    }
  }

  /// 处理ACK消息
  void _handleAckMessage(ImProtoResponse protoResponse) {
    try {
      C2CAckReq ack = C2CAckReq.fromBuffer(protoResponse.payload);
      int status = ack.status;
      String statusText;
      MessageStatus messageStatus;

      if (status == 1) {
        // 服务端status=1表示"到达服务器"，客户端直接显示"未读"（隐藏服务器ACK状态）
        statusText = "服务器已确认(显示未读)";
        messageStatus = MessageStatus.unRead;
      } else if (status == 2) {
        statusText = "对方离线";
        messageStatus = MessageStatus.unRead; // 按服务端设计，离线也显示为未读
      } else if (status == 3) {
        statusText = "对方未读";
        messageStatus = MessageStatus.unRead;
      } else if (status == 4) {
        statusText = "对方已读";
        messageStatus = MessageStatus.readed;
      } else {
        statusText = "未知状态($status)";
        messageStatus = MessageStatus.unRead; // 未知状态默认显示未读
      }

      info("★★★ [收到ACK] msgId=${ack.msgId}, 服务端状态=$statusText, 客户端显示=${messageStatus.desc} ★★★");
      
      AppEvent.onMessageStatusChanged.add(
        MessageStatusChangedModel(messageId: ack.msgId, messageStatus: messageStatus),
      );
    } catch (e, stackTrace) {
      error("❌ 解析 ACK 失败: $e\n$stackTrace");
    }
  }

  /// 处理撤回消息
  void _handleWithdrawMessage(ImProtoResponse protoResponse) {
    try {
      C2CWithdrawReq withdraw = C2CWithdrawReq.fromBuffer(protoResponse.payload);
      info("🗑️ [WITHDRAW] 收到撤回通知, msgId=${withdraw.msgId}, from=${withdraw.from}, to=${withdraw.to}");
      info("🗑️ 设置消息状态为: ${MessageStatus.withdraw.desc}");

      AppEvent.onMessageStatusChanged.add(
        MessageStatusChangedModel(messageId: withdraw.msgId, messageStatus: MessageStatus.withdraw),
      );
    } catch (e, stackTrace) {
      error("❌ 解析 WITHDRAW 失败: $e\n$stackTrace");
    }
  }

  /// 处理好友请求
  void _handleFriendRequest(ImProtoResponse protoResponse) {
    try {
      FriendRequestPush request = FriendRequestPush.fromBuffer(protoResponse.payload);

      info("============================================");
      info("📨 收到好友请求:");
      info("  申请人: ${request.fromUserName} (${request.fromUserId})");
      info("  申请消息: ${request.requestMessage}");
      info("  请求ID: ${request.requestId}");
      info("  申请人头像: ${request.fromUserAvatar}");
      info("  状态: ${request.status}");
      info("  创建时间: ${request.createTime}");
      info("  推送标题: ${request.pushTitle}");
      info("  推送内容: ${request.pushContent}");
      info("============================================");

      // 转换为FriendRequestPushMessage
      FriendRequestPushMessage pushMessage = FriendRequestPushMessage(
        pushType: 1, // 1-新的好友申请
        requestId: request.requestId,
        fromUserId: request.fromUserId,
        fromUserName: request.fromUserName,
        fromUserAvatar: request.fromUserAvatar,
        toUserId: request.toUserId,
        requestMessage: request.requestMessage,
        pushTitle: request.pushTitle,
        pushContent: request.pushContent,
        status: request.status,
        createTime: DateTime.fromMillisecondsSinceEpoch(request.createTime.toInt()),
      );

      AppEvent.onFriendRequestPush.add(pushMessage);
    } catch (e, stackTrace) {
      error("❌ 解析好友请求失败: $e\n$stackTrace");
    }
  }

  /// 处理好友响应
  void _handleFriendResponse(ImProtoResponse protoResponse) {
    try {
      FriendResponsePush response = FriendResponsePush.fromBuffer(protoResponse.payload);

      info("============================================");
      info("📬 收到好友申请响应:");
      info("  响应人: ${response.fromUserName} (${response.fromUserId})");
      info("  请求ID: ${response.requestId}");
      info("  结果: ${response.status == 1 ? '✅ 已同意' : '❌ 已拒绝'}");
      info("  推送标题: ${response.pushTitle}");
      info("  推送内容: ${response.pushContent}");
      info("============================================");

      // 转换为FriendRequestPushMessage
      FriendRequestPushMessage pushMessage = FriendRequestPushMessage(
        pushType: 2, // 2-好友申请处理结果
        requestId: response.requestId,
        fromUserId: response.fromUserId,
        fromUserName: response.fromUserName,
        fromUserAvatar: response.fromUserAvatar,
        toUserId: response.toUserId,
        requestMessage: response.pushContent,
        pushTitle: response.pushTitle,
        pushContent: response.pushContent,
        status: response.status,
        createTime: DateTime.fromMillisecondsSinceEpoch(response.responseTime.toInt()),
        handleTime: DateTime.fromMillisecondsSinceEpoch(response.responseTime.toInt()),
      );

      AppEvent.onFriendRequestPush.add(pushMessage);
    } catch (e, stackTrace) {
      error("❌ 解析好友响应失败: $e\n$stackTrace");
    }
  }

  /// 获取一个可用的消息ID
  String? _getNextMsgId() {
    info("🔍 获取消息ID - 缓存数量: ${_msgIds.length}, 正在获取中: $_isGettingMsgIds");
    
    if (_msgIds.isEmpty) {
      // 如果消息ID用完了，触发获取
      if (!_isGettingMsgIds) {
        info("📥 消息ID缓存为空，开始获取新的消息ID");
        getMsgIdsFromServer();
      } else {
        info("⏳ 正在获取消息ID中，请稍候...");
      }
      return null;
    }
    
    String msgId = _msgIds.removeAt(0);
    info("✅ 获取到消息ID: $msgId, 剩余数量: ${_msgIds.length}");
    return msgId;
  }

  // 发送消息
  Future<ChatMessage?> sendMessage(ChatMessage message) async {
    try {
      // 获取消息ID，如果失败则重试
      String? msgId = _getNextMsgId();
      if (msgId == null) {
        error("❌ 没有可用的消息ID，尝试重新获取...");
        // 重置获取状态，强制重新获取
        _isGettingMsgIds = false;
        getMsgIdsFromServer();
        
        // 等待一小段时间后再次尝试
        await Future.delayed(Duration(milliseconds: 100));
        msgId = _getNextMsgId();
        
        if (msgId == null) {
          error("❌ 重试获取消息ID失败");
          return null;
        }
      }

      // 更新消息ID
      message = message.copyWith(msgId: msgId);

      // 构建 Protobuf C2C 发送消息请求
      C2CSendReq c2cSendReq = C2CSendReq(
        msgId: message.msgId,
        from: message.fromUserId,
        to: message.toUserId,
        format: message.type,
        content: message.content,
        time: Int64(message.timestamp.millisecondsSinceEpoch),
        chatId: message.chatId,
      );

      // 包装为 ImProtoRequest
      ImProtoRequest protoRequest = ImProtoRequest(
        type: MsgType.C2C_SEND,
        payload: c2cSendReq.writeToBuffer(),
      );

      // 发送 Protobuf 二进制消息
      Uint8List bytes = protoRequest.writeToBuffer();
      _channel!.sink.add(bytes);
      info("📤 发送消息成功: msgId=$msgId, content=${message.content}");

      // 触发消息状态变化事件（发送中）
      info("📤 设置消息状态为: ${MessageStatus.sending.desc}");
      AppEvent.onMessageStatusChanged.add(
        MessageStatusChangedModel(messageId: msgId, messageStatus: MessageStatus.sending),
      );

      return message; // 返回更新后的消息对象
    } catch (e, stackTrace) {
      error("❌ 发送消息失败: $e\n$stackTrace");
      return null;
    }
  }

  // 更新会话列表（收到新消息时）
  void _updateConversationOnNewMessage(ChatMessage message) {
    info("📋 更新会话列表 - 收到新消息");
    Conversation updatedConversation = Conversation(
      name: message.fromUserId,
      headImage: 'assets/other_headImage.png',
      lastMessage: formatLastMessage(message),
      timestamp: formatMessageTimestamp(message.timestamp),
      userId: message.fromUserId,
      unreadCount: 1,
      targetUserId: message.fromUserId,
      targetUserName: message.fromUserId,
      targetUserAvatar: 'assets/other_headImage.png',
      lastMsgFormat: MessageType.fromCode(message.type),
      lastMsgId: message.msgId,
      lastMsgTime: message.timestamp.millisecondsSinceEpoch,
    );

    AppEvent.onConversationUpdated.add(updatedConversation);
  }

  // 发送接收确认
  void sendReceivedAck(String msgId, String fromUserId, String toUserId, String chatId) {
    try {
      info("📥 发送接收确认...");

      // 构建 ACK 请求
      C2CAckReq ackReq = C2CAckReq(
        msgId: msgId,
        from: toUserId, // 注意：发送方和接收方对调
        to: fromUserId,
        status: 3, // 3:未读
        chatId: chatId,
      );

      // 包装为 ImProtoRequest
      ImProtoRequest protoRequest = ImProtoRequest(
        type: MsgType.C2C_ACK,
        payload: ackReq.writeToBuffer(),
      );

      // 发送
      Uint8List bytes = protoRequest.writeToBuffer();
      _channel?.sink.add(bytes);
      info("✓ 发送接收确认完成 - status: 未读, msgId: $msgId");
    } catch (e, stackTrace) {
      error("❌ 发送接收确认失败: $e\n$stackTrace");
    }
  }

  // 发送已读确认
  void sendReadAck(String msgId, String fromUserId, String toUserId, String chatId) {
    try {
      info("👁️ 发送已读确认...");

      // 构建 ACK 请求
      C2CAckReq ackReq = C2CAckReq(
        msgId: msgId,
        from: toUserId, // 注意：发送方和接收方对调
        to: fromUserId,
        status: 4, // 4:已读
        chatId: chatId,
      );

      // 包装为 ImProtoRequest
      ImProtoRequest protoRequest = ImProtoRequest(
        type: MsgType.C2C_ACK,
        payload: ackReq.writeToBuffer(),
      );

      // 发送
      Uint8List bytes = protoRequest.writeToBuffer();
      _channel?.sink.add(bytes);
      info("✓ 发送已读确认完成 - status: 已读, msgId: $msgId");
      info("👁️ 设置消息状态为: ${MessageStatus.readed.desc}");

      AppEvent.onMessageStatusChanged.add(
        MessageStatusChangedModel(messageId: msgId, messageStatus: MessageStatus.readed),
      );
    } catch (e, stackTrace) {
      error("❌ 发送已读确认失败: $e\n$stackTrace");
    }
  }

  // 撤回消息
  void withdrawMessage(String msgId, String fromUserId, String toUserId, String chatId) {
    try {
      info("🗑️ 撤回消息...");

      // 构建撤回请求
      C2CWithdrawReq withdrawReq = C2CWithdrawReq(
        msgId: msgId,
        from: fromUserId,
        to: toUserId,
        chatId: chatId,
      );

      // 包装为 ImProtoRequest
      ImProtoRequest protoRequest = ImProtoRequest(
        type: MsgType.C2C_WITHDRAW,
        payload: withdrawReq.writeToBuffer(),
      );

      // 发送
      Uint8List bytes = protoRequest.writeToBuffer();
      _channel?.sink.add(bytes);
      info("✓ 撤回消息完成: msgId=$msgId");
    } catch (e, stackTrace) {
      error("❌ 撤回消息失败: $e\n$stackTrace");
    }
  }

  // 请求会话列表（暂时保留，可能需要HTTP API）
  void requestConversations() {
    info("📋 请求会话列表...");
    // TODO: 会话列表可能需要通过HTTP API获取，而不是WebSocket
  }

  /// 检查消息ID状态（用于调试）
  void checkMsgIdStatus() {
    info("========== 消息ID状态检查 ==========");
    info("📊 WebSocket连接状态: ${_channel != null ? '已连接' : '未连接'}");
    info("📊 当前缓存消息ID数量: ${_msgIds.length}");
    info("📊 正在获取消息ID: $_isGettingMsgIds");
    info("📊 当前用户ID: $_currentUserId");
    info("📊 WebSocket状态: ${AppEvent.webSocketStatus.value}");
    if (_msgIds.isNotEmpty) {
      info("📊 缓存中的前3个消息ID: ${_msgIds.take(3).toList()}");
    }
    info("=====================================");
  }

  /// 手动触发获取消息ID（用于调试）
  void forceGetMsgIds() {
    info("🔄 手动强制获取消息ID");
    _isGettingMsgIds = false; // 重置状态
    getMsgIdsFromServer();
  }

  void disconnect() async {
    info("🔌 断开WebSocket连接");
    await _channel?.sink.close();
    AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
  }

  @override
  void onClose() {
    _channel?.sink.close();
    super.onClose();
  }
}
