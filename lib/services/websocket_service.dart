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
import 'package:xzll_im_flutter_client/services/data_base_service.dart';
import 'package:xzll_im_flutter_client/utils/uuid_generator.dart';
import 'package:xzll_im_flutter_client/utils/proto_converter_util.dart';
import 'package:xzll_im_flutter_client/utils/chat_id_utils.dart';

/// WebSocket服务类 - Protobuf版本
class WebSocketService extends GetxService {
  IOWebSocketChannel? _channel;

  // ✅ 延迟获取 AppData，避免在 WebSocketService 初始化时 AppData 还未注册
  AppData get appData => Get.find<AppData>();
  
  // ✅ 数据库服务，用于保存消息
  DataBaseService get _databaseService => Get.find<DataBaseService>();

  String get _currentUserId => appData.user.value.id;

  late int retryCount = AppConfig.webSocketRetryCount;

  // 消息ID现在由服务端生成，移除客户端缓存机制
  // final List<String> _msgIds = [];  // 已删除
  // bool _isGettingMsgIds = false;    // 已删除

  // 心跳相关（优化版：完全依赖WebSocket协议层pingInterval自动处理）
  // ✅ 已移除：_heartbeatTimer, _lastHeartbeatTime, _heartbeatInterval（不再需要应用层心跳检查）
  // ✅ 心跳由 IOWebSocketChannel 的 pingInterval 参数自动处理（协议层ping/pong帧）
  
  // ✅ 自动重连增强
  Timer? _reconnectTimer; // 重连定时器
  int _reconnectAttempts = 0; // 当前重连尝试次数
  static const int _maxReconnectAttempts = 999999; // 最大重连次数（几乎无限）
  static const Duration _minReconnectDelay = Duration(seconds: 1); // 最小重连间隔
  static const Duration _maxReconnectDelay = Duration(seconds: 30); // 最大重连间隔
  bool _isManualDisconnect = false; // 是否是手动断开连接
  bool _isAppInBackground = false; // 应用是否在后台

  @override
  void onInit() {
    super.onInit();
    AppEvent.networkStatus.stream.listen(_onNetworkStatusChanged);
  }
  
  /// 设置应用是否在后台（由AppLifecycleService调用）
  void setAppInBackground(bool inBackground) {
    _isAppInBackground = inBackground;
    if (inBackground) {
      info("📱 应用进入后台（协议层心跳继续工作）");
    } else {
      info("📱 应用回到前台（协议层心跳继续工作）");
    }
  }

  ///监听网络状态的变化
  void _onNetworkStatusChanged(ConnectivityStatus status) async {
    info("📡 网络状态变化: ${status.name}");
    switch (status) {
      case ConnectivityStatus.normal:
        info("✅ 网络已恢复，准备重连...");
        _reconnectAttempts = 0; // ✅ 重置重连次数
        _scheduleReconnect(immediate: true); // ✅ 立即重连
        break;
      case ConnectivityStatus.none:
        {
          info("❌ 网络断开");
          _cancelReconnect(); // ✅ 取消重连定时器
          if (_channel != null) {
            await _channel!.sink.close();
          }
          AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
          break;
        }
    }
  }

  ///初始化WebSocket
  Future<void> initWebSocket() async {
    // ✅ 检查是否已经连接，避免重复初始化
    if (_channel != null && AppEvent.webSocketStatus.value == WebSocketStatus.connected) {
      info("✅ WebSocket已连接，无需重复初始化");
      return;
    }
    
    if (appData.token.isEmpty || appData.user.value.id.isEmpty || appData.refreshToken.isEmpty) {
      waring("⚠️ 用户未登录，无法初始化WebSocket");
      return;
    }
    
    // ✅ 如果有旧连接，先关闭
    if (_channel != null) {
      info("⚠️ 检测到旧连接，先关闭");
      try {
        await _channel!.sink.close();
      } catch (e) {
        error("关闭旧连接失败: $e");
      }
      _channel = null;
    }
    
    final wsUrl = AppConfig.getWebSocketUrl(_currentUserId);
    final headers = {
      'Connection': 'Upgrade',
      'Upgrade': 'websocket',
      'token': appData.token.value,
      'uid': _currentUserId,
    };
    
    try {
      info("🔗 开始建立WebSocket连接...");
      AppEvent.webSocketStatus.add(WebSocketStatus.connecting);
      
      // ✅ 创建WebSocket连接，启用ping/pong帧自动处理 不使用应用层ping、pong 改用协议层，性能好，无需手动处理。
      _channel = IOWebSocketChannel.connect(
        wsUrl, 
        headers: headers,
        pingInterval: Duration(seconds: 25), // 启用客户端ping
      );
      AppEvent.webSocketStatus.add(WebSocketStatus.connected);
      
      // ✅ 连接成功，重置重连相关状态
      retryCount = AppConfig.webSocketRetryCount;
      _reconnectAttempts = 0;
      _cancelReconnect();
      
      _channel?.stream.listen(_onData, onError: _onError, onDone: _onDone);
      
      // 连接成功，协议层心跳自动工作（pingInterval已配置）
      info("✅ WebSocket连接成功（协议层心跳已启用）");
    } catch (e) {
      error("❌ WebSocket连接失败: $e");
      AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
      
      // ✅ 连接失败，触发自动重连
      _scheduleReconnect();
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
    
    // ✅ 如果不是手动断开，则触发自动重连
    if (!_isManualDisconnect) {
      info("🔄 连接意外断开，准备自动重连...");
      _scheduleReconnect();
    } else {
      info("👋 手动断开连接，不进行重连");
    }
  }

  void _onError(Object e, StackTrace stackTrace) {
    AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
    error("❌ WebSocket错误: $e  $stackTrace");
    
    // ✅ 发生错误，触发自动重连
    if (!_isManualDisconnect) {
      info("🔄 连接出错，准备自动重连...");
      _scheduleReconnect();
    }
  }

  // ==================== 消息ID获取机制已移除 ====================
  // 消息ID现在由服务端在接收消息时生成，客户端无需预先获取
  // 移除了 getMsgIdsFromServer() 方法

  // 处理接收到的消息
  void _onData(dynamic message) {
    try {
      // ✅ 调试：打印接收到的消息类型和内容
      info("🔍 [DEBUG] 收到消息 - 类型: ${message.runtimeType}");
      if (message is String) {
        info("🔍 [DEBUG] 文本消息内容: '$message'");
      } else if (message is List<int>) {
        info("🔍 [DEBUG] 二进制消息长度: ${message.length}");
        if (message.length <= 20) { // 只打印短消息的内容
          info("🔍 [DEBUG] 二进制消息内容: $message");
          String textForm = String.fromCharCodes(message);
          info("🔍 [DEBUG] 转换为文本: '$textForm'");
        }
      }
      
      // ✅ 文本消息处理（服务端仅支持 Protobuf 二进制格式）
      if (message is String) {
        // 服务端不接受文本消息，如果收到说明有问题
        info("⚠️ 收到意外的文本消息（服务端仅支持 Protobuf）: $message");
        return;
      }
      
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
          // 批量消息ID功能已移除 - 消息ID现在由服务端生成
          info("⚠️ 收到批量消息ID推送，但该功能已禁用（消息ID现由服务端生成）");
          break;

        case MsgType.C2C_ACK:
          // 处理ACK消息（双轨制：通过receiveStatus等字段区分服务端和客户端ACK）
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

  /// 处理推送消息（单聊消息）- 双轨制（优化后：适配bytes/fixed64，chatId动态生成）
  void _handlePushMsg(ImProtoResponse protoResponse) {
    try {
      C2CMsgPush pushMsg = C2CMsgPush.fromBuffer(protoResponse.payload);

      // 类型转换：bytes/fixed64 -> String
      String clientMsgId = ProtoConverterUtil.bytesToUuidString(pushMsg.clientMsgId);
      String msgId = ProtoConverterUtil.int64ToSnowflakeString(pushMsg.msgId);
      String from = ProtoConverterUtil.int64ToSnowflakeString(pushMsg.from);
      String to = ProtoConverterUtil.int64ToSnowflakeString(pushMsg.to);
      // chatId动态生成（与服务端逻辑一致）
      String chatId = ChatIdUtils.generateC2CChatId(from, to);

      // ✅ 上下文感知：根据会话打开状态决定消息初始状态
      String messageChatId = chatId;
      String currentOpenChatId = AppEvent.currentOpenChatId.value;
      bool isChatOpen = messageChatId == currentOpenChatId && currentOpenChatId.isNotEmpty;
      MessageStatus initialStatus = isChatOpen ? MessageStatus.readed : MessageStatus.unRead;
      
      info("============================================");
      info("【收到单聊消息（双轨制优化版）】");
      info("  客户端消息ID: $clientMsgId");
      info("  服务端消息ID: $msgId");
      info("  发送人: $from");
      info("  接收人: $to");
      info("  消息格式: ${pushMsg.format}");
      info("  消息内容: ${pushMsg.content}");
      info("  时间戳: ${pushMsg.time}");
      info("  会话ID(动态): $chatId");
      info("  当前打开会话: $currentOpenChatId");
      info("  会话是否打开: $isChatOpen");
      info("  初始状态: ${initialStatus.desc}");
      info("============================================");

      // 转换为ChatMessage（双轨制：保存两个ID，状态根据会话打开状态决定）
      ChatMessage message = ChatMessage(
        clientMsgId: clientMsgId, // 客户端消息ID
        msgId: msgId, // 服务端消息ID
        fromUserId: from,
        toUserId: to,
        content: pushMsg.content,
        timestamp: DateTime.fromMillisecondsSinceEpoch(pushMsg.time.toInt()),
        type: pushMsg.format,
        chatId: chatId, // 动态生成的chatId
        status: initialStatus, // ✅ 根据会话打开状态决定初始状态
      );

      // ✅ 发送事件通知（给打开的聊天界面）
      AppEvent.onMessageReceived.add(message);

      // ✅ 保存消息到本地数据库（状态已经是正确的）
      _saveMessageToDatabase(message);

      // ✅ 上下文感知ACK：自动根据会话打开状态发送智能ACK
      _sendSmartAck(clientMsgId, msgId, from, to);
      
      // 更新会话列表
      _updateConversationOnNewMessage(message);
    } catch (e, stackTrace) {
      error("❌ 解析 C2CMsgPush 失败: $e\n$stackTrace");
    }
  }

  // ==================== 批量消息ID处理已移除 ====================
  // _handleBatchMsgIds 方法已移除，消息ID现在由服务端在接收消息时生成

  /// 处理ACK消息 - 双轨制（使用 clientMsgId 匹配，更新 serverMsgId）（优化后：适配bytes/fixed64）
  void _handleAckMessage(ImProtoResponse protoResponse) {
    try {
      C2CAckReq ack = C2CAckReq.fromBuffer(protoResponse.payload);
      
      // 类型转换：bytes/fixed64 -> String
      String clientMsgId = ProtoConverterUtil.bytesToUuidString(ack.clientMsgId);
      String msgId = ProtoConverterUtil.int64ToSnowflakeString(ack.msgId);
      
      int status = ack.status;
      String statusText;
      MessageStatus messageStatus;

      if (status == 1) {
        // 服务端status=1表示"到达服务器"，客户端直接显示"未读"（隐藏服务器ACK状态）
        statusText = "服务器已确认(显示未读)";
        messageStatus = MessageStatus.serverReceived; // 改为服务器已接收状态
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

      info("★★★ [收到ACK（双轨制优化版）] 客户端ID=$clientMsgId, 服务端ID=$msgId, 状态=$statusText ★★★");
      
      // 双轨制方案1：
      // 1. 使用 clientMsgId 匹配消息
      // 2. 更新消息的 serverMsgId（后续撤回/删除用这个）
      // 3. 更新消息状态
      AppEvent.onMessageStatusChanged.add(
        MessageStatusChangedModel(
          messageId: clientMsgId, 
          messageStatus: messageStatus,
          serverMsgId: msgId.isNotEmpty ? msgId : null, // ✅ 传递 serverMsgId
        ),
      );
    } catch (e, stackTrace) {
      error("❌ 解析 ACK 失败: $e\n$stackTrace");
    }
  }

  /// 处理撤回消息 - 双轨制（使用 serverMsgId 匹配）（优化后：适配fixed64）
  void _handleWithdrawMessage(ImProtoResponse protoResponse) {
    try {
      C2CWithdrawReq withdraw = C2CWithdrawReq.fromBuffer(protoResponse.payload);
      
      // 类型转换：fixed64 -> String
      String msgId = ProtoConverterUtil.int64ToSnowflakeString(withdraw.msgId);
      String from = ProtoConverterUtil.int64ToSnowflakeString(withdraw.from);
      String to = ProtoConverterUtil.int64ToSnowflakeString(withdraw.to);
      
      info("🗑️ [WITHDRAW（双轨制优化版）] 收到撤回通知");
      info("   服务端ID: $msgId");
      info("   发起人: $from");
      info("   接收人: $to");
      info("   撤回状态: ${MessageStatus.withdraw.desc}");

      // 双轨制方案1：
      // 撤回操作使用 serverMsgId，因为：
      // 1. 此时消息已发送成功，一定有 serverMsgId
      // 2. 服务端数据库操作也是用 serverMsgId
      // 3. UI 层会用双ID匹配方法查找消息（优先 clientMsgId，其次 serverMsgId）
      AppEvent.onMessageStatusChanged.add(
        MessageStatusChangedModel(
          messageId: msgId, // 使用转换后的 serverMsgId String
          messageStatus: MessageStatus.withdraw
        ),
      );
    } catch (e, stackTrace) {
      error("❌ 解析 WITHDRAW 失败: $e\n$stackTrace");
    }
  }

  /// 处理好友请求（优化后：适配fixed64）
  void _handleFriendRequest(ImProtoResponse protoResponse) {
    try {
      FriendRequestPush request = FriendRequestPush.fromBuffer(protoResponse.payload);

      // 类型转换：fixed64 -> String, bytes -> UUID String
      String toUserId = ProtoConverterUtil.int64ToSnowflakeString(request.toUserId);
      String requestId = ProtoConverterUtil.bytesToUuidString(request.requestId); // UUID bytes -> String
      String fromUserId = ProtoConverterUtil.int64ToSnowflakeString(request.fromUserId);

      info("============================================");
      info("📨 收到好友请求(优化版):");
      info("  申请人: ${request.fromUserName} ($fromUserId)");
      info("  申请消息: ${request.requestMessage}");
      info("  请求ID: $requestId");
      info("  申请人头像: ${request.fromUserAvatar}");
      info("  状态: ${request.status}");
      info("  创建时间: ${request.createTime}");
      info("  推送标题: ${request.pushTitle}");
      info("  推送内容: ${request.pushContent}");
      info("============================================");

      // 转换为FriendRequestPushMessage
      FriendRequestPushMessage pushMessage = FriendRequestPushMessage(
        pushType: 1, // 1-新的好友申请
        requestId: requestId,
        fromUserId: fromUserId,
        fromUserName: request.fromUserName,
        fromUserAvatar: request.fromUserAvatar,
        toUserId: toUserId,
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

  /// 处理好友响应（优化后：适配fixed64）
  void _handleFriendResponse(ImProtoResponse protoResponse) {
    try {
      FriendResponsePush response = FriendResponsePush.fromBuffer(protoResponse.payload);

      // 类型转换：fixed64 -> String, bytes -> UUID String
      String toUserId = ProtoConverterUtil.int64ToSnowflakeString(response.toUserId);
      String requestId = ProtoConverterUtil.bytesToUuidString(response.requestId); // UUID bytes -> String
      String fromUserId = ProtoConverterUtil.int64ToSnowflakeString(response.fromUserId);

      info("============================================");
      info("📬 收到好友申请响应(优化版):");
      info("  响应人: ${response.fromUserName} ($fromUserId)");
      info("  请求ID: $requestId");
      info("  结果: ${response.status == 1 ? '✅ 已同意' : '❌ 已拒绝'}");
      info("  推送标题: ${response.pushTitle}");
      info("  推送内容: ${response.pushContent}");
      info("============================================");

      // 转换为FriendRequestPushMessage
      FriendRequestPushMessage pushMessage = FriendRequestPushMessage(
        pushType: 2, // 2-好友申请处理结果
        requestId: requestId,
        fromUserId: fromUserId,
        fromUserName: response.fromUserName,
        fromUserAvatar: response.fromUserAvatar,
        toUserId: toUserId,
        requestMessage: response.pushContent,
        pushTitle: response.pushTitle,
        pushContent: response.pushContent,
        status: response.status,
        createTime: DateTime.fromMillisecondsSinceEpoch(response.responseTime.toInt()),
        handleTime: DateTime.fromMillisecondsSinceEpoch(response.responseTime.toInt()),
      );

      AppEvent.onFriendRequestPush.add(pushMessage);

      // ✅ 如果好友申请被同意，触发好友列表刷新
      if (response.status == 1) {
        info("🔄 好友申请已通过，触发好友列表刷新");
        AppEvent.onFriendListRefresh.add(true);
      }
    } catch (e, stackTrace) {
      error("❌ 解析好友响应失败: $e\n$stackTrace");
    }
  }

  // ==================== 消息ID获取方法已移除 ====================
  // _getNextMsgId() 方法已移除，消息ID现在由服务端生成

  // 发送消息（双轨制：客户端生成 UUID，服务端生成雪花ID）（优化后：适配bytes/fixed64，chatId不传）
  Future<ChatMessage?> sendMessage(ChatMessage message) async {
    try {
      // 生成客户端消息ID（UUID，全局唯一）
      final clientMsgId = UuidGenerator.generateClientMsgId();
      info("📤 准备发送消息(优化版)，客户端ID: $clientMsgId, 内容: ${message.content}");
      
      // 使用客户端ID更新消息对象（服务端ID为空字符串，等待服务端生成）
      message = message.copyWith(clientMsgId: clientMsgId, msgId: '');

      // 构建 Protobuf C2C 发送消息请求（双轨制优化版：clientMsgId=bytes，msgId=0，chatId不传）
      C2CSendReq c2cSendReq = C2CSendReq(
        clientMsgId: ProtoConverterUtil.uuidStringToBytes(clientMsgId),  // UUID String -> bytes
        msgId: Int64.ZERO,  // 服务端消息ID（0表示留空，由服务端生成）
        from: ProtoConverterUtil.snowflakeStringToInt64(message.fromUserId),  // String -> fixed64
        to: ProtoConverterUtil.snowflakeStringToInt64(message.toUserId),  // String -> fixed64
        format: message.type,
        content: message.content,
        time: Int64(message.timestamp.millisecondsSinceEpoch),  // fixed64
        // chatId 已从proto删除，服务端会根据from+to动态生成
      );

      // 包装为 ImProtoRequest
      ImProtoRequest protoRequest = ImProtoRequest(
        type: MsgType.C2C_SEND,
        payload: c2cSendReq.writeToBuffer(),
      );

      // 发送 Protobuf 二进制消息
      Uint8List bytes = protoRequest.writeToBuffer();
      _channel!.sink.add(bytes);
      info("📤 消息已发送到服务端（双轨制优化版），客户端ID: $clientMsgId");

      // 触发消息状态变化事件（发送中）- 使用 clientMsgId 作为唯一标识
      AppEvent.onMessageStatusChanged.add(
        MessageStatusChangedModel(messageId: clientMsgId, messageStatus: MessageStatus.sending),
      );

      // ✅ 发送消息后，立即更新会话列表
      _updateConversationOnSendMessage(message);

      return message; // 返回带客户端ID的消息对象
    } catch (e, stackTrace) {
      error("❌ 发送消息失败: $e\n$stackTrace");
      return null;
    }
  }

  /// 保存消息到本地数据库
  Future<void> _saveMessageToDatabase(ChatMessage message) async {
    try {
      info("💾 保存消息到数据库: msgId=${message.msgId}, content=${message.content}");
      await _databaseService.insertMessage(message);
      
      // 同时更新会话信息
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
        chatId: message.chatId,
      );
      
      await _databaseService.insertOrUpdateConversation(updatedConversation);
      info("✅ 消息和会话已保存到数据库");
    } catch (e) {
      error("❌ 保存消息到数据库失败: $e");
    }
  }

  // 更新会话列表（收到新消息时）
  void _updateConversationOnNewMessage(ChatMessage message) {
    info("📋 更新会话列表 - 收到新消息");
    
    // 当前用户ID
    String currentUserId = appData.user.value.id;
    
    // 对方是发送人（因为是收到的消息）
    String targetUserId = message.fromUserId;
    
    // ✅ 根据会话是否打开来决定未读数
    String messageChatId = message.chatId;
    String currentOpenChatId = AppEvent.currentOpenChatId.value;
    bool isChatOpen = messageChatId == currentOpenChatId && currentOpenChatId.isNotEmpty;
    int unreadCount = isChatOpen ? 0 : 1; // 会话打开则未读数为0，否则为1
    
    info("📋 会话更新 - chatId: $messageChatId, 当前打开: $currentOpenChatId, 未读数: $unreadCount");
    
    Conversation updatedConversation = Conversation(
      name: targetUserId,
      headImage: 'assets/other_headImage.png',
      lastMessage: formatLastMessage(message),
      timestamp: formatMessageTimestamp(message.timestamp),
      userId: currentUserId,
      unreadCount: unreadCount, // ✅ 根据会话状态设置未读数
      targetUserId: targetUserId,
      targetUserName: targetUserId,
      targetUserAvatar: 'assets/other_headImage.png',
      lastMsgFormat: MessageType.fromCode(message.type),
      lastMsgId: message.msgId,
      lastMsgTime: message.timestamp.millisecondsSinceEpoch,
      chatId: message.chatId, // 使用消息中的chatId
    );

    AppEvent.onConversationUpdated.add(updatedConversation);
  }

  // 更新会话列表（发送消息时）
  void _updateConversationOnSendMessage(ChatMessage message) {
    info("📋 更新会话列表 - 发送新消息");
    
    // 当前用户ID
    String currentUserId = appData.user.value.id;
    
    // 对方是接收人（因为是发送的消息）
    String targetUserId = message.toUserId;
    
    Conversation updatedConversation = Conversation(
      name: targetUserId,
      headImage: 'assets/other_headImage.png',
      lastMessage: formatLastMessage(message),
      timestamp: formatMessageTimestamp(message.timestamp),
      userId: currentUserId,
      unreadCount: 0, // 自己发送的消息，未读数为0
      targetUserId: targetUserId,
      targetUserName: targetUserId,
      targetUserAvatar: 'assets/other_headImage.png',
      lastMsgFormat: MessageType.fromCode(message.type),
      lastMsgId: message.msgId,
      lastMsgTime: message.timestamp.millisecondsSinceEpoch,
      chatId: message.chatId, // 使用消息中的chatId
    );

    AppEvent.onConversationUpdated.add(updatedConversation);
  }

  /// ✅ 上下文感知ACK：根据会话打开状态智能发送ACK
  /// 如果会话已打开 → 发送已读ACK（status=4）
  /// 如果会话未打开 → 发送未读ACK（status=3）
  void _sendSmartAck(String clientMsgId, String serverMsgId, String fromUserId, String toUserId) {
    try {
      // 动态生成chatId（与服务端逻辑一致）
      String messageChatId = ChatIdUtils.generateC2CChatId(fromUserId, toUserId);
      
      // 获取当前打开的会话ID
      String currentOpenChatId = AppEvent.currentOpenChatId.value;
      
      // 智能决策：会话打开则已读，否则未读
      bool isChatOpen = messageChatId == currentOpenChatId && currentOpenChatId.isNotEmpty;
      int status = isChatOpen ? 4 : 3; // 4=已读, 3=未读
      String statusDesc = isChatOpen ? "已读(会话打开)" : "未读(会话未打开)";
      
      info("🧠 [上下文感知ACK] 消息chatId: $messageChatId, 当前打开: $currentOpenChatId");
      info("   → 决策: 发送 $statusDesc ACK");

      // 构建 ACK 请求（双轨制优化版：clientMsgId=bytes, msgId/from/to=fixed64, chatId已删除）
      C2CAckReq ackReq = C2CAckReq(
        clientMsgId: ProtoConverterUtil.uuidStringToBytes(clientMsgId), // String -> bytes
        msgId: ProtoConverterUtil.snowflakeStringToInt64(serverMsgId), // String -> fixed64
        from: ProtoConverterUtil.snowflakeStringToInt64(toUserId), // 注意：发送方和接收方对调, String -> fixed64
        to: ProtoConverterUtil.snowflakeStringToInt64(fromUserId), // String -> fixed64
        status: status, // 智能决策的状态
        // chatId 已从proto删除，服务端会动态生成
      );

      // 包装为 ImProtoRequest
      ImProtoRequest protoRequest = ImProtoRequest(
        type: MsgType.C2C_ACK,
        payload: ackReq.writeToBuffer(),
      );

      // 发送
      Uint8List bytes = protoRequest.writeToBuffer();
      _channel?.sink.add(bytes);
      info("✓ [上下文感知ACK] 发送完成 - status: $statusDesc, clientMsgId: $clientMsgId, serverMsgId: $serverMsgId");
    } catch (e, stackTrace) {
      error("❌ 发送智能ACK失败: $e\n$stackTrace");
    }
  }

  // 发送已读确认（双轨制：传递两个ID）（优化后：适配bytes/fixed64，chatId不传）
  void sendReadAck(String clientMsgId, String serverMsgId, String fromUserId, String toUserId) {
    try {
      info("👁️ 发送已读确认（双轨制优化版）...");

      // 构建 ACK 请求（双轨制优化版：clientMsgId=bytes, msgId/from/to=fixed64, chatId已删除）
      C2CAckReq ackReq = C2CAckReq(
        clientMsgId: ProtoConverterUtil.uuidStringToBytes(clientMsgId), // String -> bytes
        msgId: ProtoConverterUtil.snowflakeStringToInt64(serverMsgId), // String -> fixed64
        from: ProtoConverterUtil.snowflakeStringToInt64(toUserId), // 注意：发送方和接收方对调, String -> fixed64
        to: ProtoConverterUtil.snowflakeStringToInt64(fromUserId), // String -> fixed64
        status: 4, // 4:已读
        // chatId 已从proto删除，服务端会动态生成
      );

      // 包装为 ImProtoRequest
      ImProtoRequest protoRequest = ImProtoRequest(
        type: MsgType.C2C_ACK,
        payload: ackReq.writeToBuffer(),
      );

      // 发送
      Uint8List bytes = protoRequest.writeToBuffer();
      _channel?.sink.add(bytes);
      info("✓ 发送已读确认完成(优化版) - status: 已读, 客户端ID: $clientMsgId, 服务端ID: $serverMsgId");
      info("👁️ 设置消息状态为: ${MessageStatus.readed.desc}");

      // 使用 clientMsgId 更新消息状态
      AppEvent.onMessageStatusChanged.add(
        MessageStatusChangedModel(messageId: clientMsgId, messageStatus: MessageStatus.readed),
      );
    } catch (e, stackTrace) {
      error("❌ 发送已读确认失败: $e\n$stackTrace");
    }
  }

  // 撤回消息（优化后：适配fixed64，chatId不传）
  void withdrawMessage(String msgId, String fromUserId, String toUserId) {
    try {
      info("🗑️ 撤回消息(优化版)...");

      // 构建撤回请求（优化版：msgId/from/to=fixed64, chatId已删除）
      C2CWithdrawReq withdrawReq = C2CWithdrawReq(
        msgId: ProtoConverterUtil.snowflakeStringToInt64(msgId), // String -> fixed64
        from: ProtoConverterUtil.snowflakeStringToInt64(fromUserId), // String -> fixed64
        to: ProtoConverterUtil.snowflakeStringToInt64(toUserId), // String -> fixed64
        // chatId 已从proto删除，服务端会动态生成
      );

      // 包装为 ImProtoRequest
      ImProtoRequest protoRequest = ImProtoRequest(
        type: MsgType.C2C_WITHDRAW,
        payload: withdrawReq.writeToBuffer(),
      );

      // 发送
      Uint8List bytes = protoRequest.writeToBuffer();
      _channel?.sink.add(bytes);
      info("✓ 撤回消息完成(优化版): msgId=$msgId");
    } catch (e, stackTrace) {
      error("❌ 撤回消息失败: $e\n$stackTrace");
    }
  }

  // 请求会话列表（暂时保留，可能需要HTTP API）
  void requestConversations() {
    info("📋 请求会话列表...");
    // TODO: 会话列表可能需要通过HTTP API获取，而不是WebSocket
  }

  /// 检查WebSocket连接状态（用于调试）
  void checkConnectionStatus() {
    info("========== WebSocket连接状态检查 ==========");
    info("📊 WebSocket连接状态: ${_channel != null ? '已连接' : '未连接'}");
    info("📊 当前用户ID: $_currentUserId");
    info("📊 WebSocket状态: ${AppEvent.webSocketStatus.value}");
    info("💓 心跳状态: 协议层自动处理（pingInterval: 25秒）");
    info("=====================================");
  }

  // ==================== 消息ID相关调试方法已移除 ====================
  // forceGetMsgIds() 方法已移除，消息ID现在由服务端生成

  // ==================== 心跳机制 ====================
  // ✅ 心跳完全由 WebSocket 协议层处理（IOWebSocketChannel 的 pingInterval 参数）
  // ✅ 无需应用层心跳检查，连接断开时会自动触发 _onDone 或 _onError

  void disconnect() async {
    info("🔌 手动断开WebSocket连接");
    
    // ✅ 标记为手动断开，防止自动重连
    _isManualDisconnect = true;
    
    // 取消重连定时器
    _cancelReconnect();
    
    await _channel?.sink.close();
    AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
  }
  
  // ==================== 智能自动重连机制 ====================
  
  /// 安排重连（指数退避算法）
  void _scheduleReconnect({bool immediate = false}) {
    // 如果是手动断开，不进行重连
    if (_isManualDisconnect) {
      info("⏸️ 手动断开状态，跳过重连");
      return;
    }
    
    // 检查是否已达到最大重连次数
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      error("❌ 已达到最大重连次数 ($_maxReconnectAttempts)，停止重连");
      return;
    }
    
    // 取消之前的重连定时器
    _cancelReconnect();
    
    // 计算重连延迟（指数退避：1s, 2s, 4s, 8s, 16s, 30s）
    Duration delay;
    if (immediate) {
      delay = Duration.zero;
    } else {
      final exponentialDelay = _minReconnectDelay * (1 << _reconnectAttempts.clamp(0, 5));
      delay = exponentialDelay > _maxReconnectDelay ? _maxReconnectDelay : exponentialDelay;
      
      // ✅ 如果应用在后台，使用更长的重连间隔以节省资源
      if (_isAppInBackground) {
        delay = delay * 2; // 后台重连间隔加倍
        if (delay > Duration(seconds: 60)) {
          delay = Duration(seconds: 60); // 最长60秒
        }
      }
    }
    
    _reconnectAttempts++;
    final bgInfo = _isAppInBackground ? "（后台模式）" : "";
    info("🔄 安排第 $_reconnectAttempts 次重连$bgInfo，延迟: ${delay.inSeconds}秒");
    
    // 设置重连定时器
    _reconnectTimer = Timer(delay, () {
      info("🔄 开始第 $_reconnectAttempts 次重连尝试...");
      _performReconnect();
    });
  }
  
  /// 执行重连
  Future<void> _performReconnect() async {
    // 再次检查是否手动断开
    if (_isManualDisconnect) {
      info("⏸️ 手动断开状态，取消重连");
      return;
    }
    
    // 检查是否已经连接
    if (AppEvent.webSocketStatus.value == WebSocketStatus.connected) {
      info("✅ 已经处于连接状态，跳过重连");
      _reconnectAttempts = 0;
      return;
    }
    
    info("🔄 正在执行重连...");
    AppEvent.webSocketStatus.add(WebSocketStatus.reconnecting);
    
    try {
      // 关闭旧连接
      await _channel?.sink.close();
      
      // 尝试重新连接
      await initWebSocket();
      
      // initWebSocket 内部会处理成功和失败的情况
    } catch (e) {
      error("❌ 重连失败: $e");
      AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
      
      // 继续安排下一次重连
      _scheduleReconnect();
    }
  }
  
  /// 取消重连定时器
  void _cancelReconnect() {
    if (_reconnectTimer != null) {
      info("⏹️ 取消重连定时器");
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    }
  }

  @override
  void onClose() {
    _isManualDisconnect = true;
    _cancelReconnect();
    _channel?.sink.close();
    super.onClose();
  }
}
