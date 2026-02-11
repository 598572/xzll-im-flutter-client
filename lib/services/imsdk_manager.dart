import 'dart:async';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';
import 'package:xzll_im_flutter_client/models/domain/message_status_changed_model.dart';
import 'package:xzll_im_flutter_client/models/enum/message_status.dart';
import 'package:xzll_im_flutter_client/models/enum/message_type.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';
import 'package:xzll_im_sdk/xzll_im_sdk.dart';

// 用于Completer的类型别名
typedef MessageCompleter = Completer<ChatMessage?>;

/// IM SDK 管理类
///
/// 包装 XZLLIMClient，提供与现有代码兼容的接口
class IMSDKManager extends GetxService {
  static IMSDKManager get to => Get.find();

  // SDK客户端
  final XZLLIMClient _imClient = XZLLIMClient();

  // AppData
  AppData get _appData => Get.find<AppData>();

  // 是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // 应用是否在后台
  bool _isAppInBackground = false;

  // 消息发送完成回调流
  final _messageStatusController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStatusStream => _messageStatusController.stream;

  // ✅ 已发送ACK的消息记录（用于去重）
  final _sentAckMessages = <String>{};

  @override
  void onInit() {
    super.onInit();
    info('IMSDKManager 初始化');
  }

  /// 初始化SDK
  Future<void> init() async {
    if (_isInitialized) {
      info('SDK已经初始化，跳过');
      return;
    }

    try {
      // 1. 创建配置
      final config = XZLLIMConfig.dev(
        appId: 'xzll-im-client',
      );

      // 2. 初始化SDK
      _imClient.init(config);

      // 3. 监听连接状态
      _imClient.connectionStatusStream.listen((status) {
        _handleConnectionStatusChange(status);
      });

      // 4. 设置消息监听
      _imClient.setMessageListener(_onMessageReceived);

      // 5. 设置消息状态监听
      _imClient.setMessageStatusListener(_onMessageStatusChanged);

      _isInitialized = true;
      info('✅ IM SDK 初始化成功');
    } catch (e) {
      error('❌ IM SDK 初始化失败: $e');
      rethrow;
    }
  }

  /// 连接服务器
  Future<void> connect() async {
    if (!_isInitialized) {
      error('SDK未初始化');
      return;
    }

    final userId = _appData.user.value.id;
    final token = _appData.token.value;
    final refreshToken = _appData.refreshToken.value;

    if (userId.isEmpty || token.isEmpty) {
      error('用户未登录，无法连接IM服务器');
      return;
    }

    info('🔗 开始连接IM服务器...');
    AppEvent.webSocketStatus.add(WebSocketStatus.connecting);

    await _imClient.connect(
      userId,
      token,
      refreshToken,
      callback: (success, {errorMsg}) {
        if (success) {
          info('✅ IM服务器连接成功');
        } else {
          error('❌ IM服务器连接失败: $errorMsg');
          AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
        }
      },
    );
  }

  /// 断开连接
  void disconnect() {
    info('🔌 断开IM服务器连接');
    _imClient.disconnect();
  }

  /// 设置当前打开的会话ID（用于上下文感知ACK）
  ///
  /// 当用户打开聊天界面时调用此方法，SDK会自动根据会话打开状态发送已读/未读ACK
  void setCurrentOpenChatId(String chatId) {
    _imClient.setCurrentOpenChatId(chatId);
    info('📌 设置当前打开会话: $chatId');
  }

  /// 打开一个聊天会话（推荐使用）⭐
  ///
  /// 返回一个[ChatSessionManager]实例，退出时调用[close]方法
  /// SDK会自动根据会话状态发送已读/未读ACK
  ///
  /// 使用示例：
  /// ```dart
  /// // 进入聊天窗口
  /// final session = _imSdkManager.openChatSession(chatId);
  ///
  /// // 退出聊天窗口
  /// session.close();
  /// ```
  ChatSessionManager openChatSession(String chatId) {
    return _imClient.openChatSession(chatId);
  }

  /// 发送消息
  Future<ChatMessage?> sendMessage(ChatMessage message) async {
    if (!_imClient.isConnected) {
      error('未连接到IM服务器');
      return null;
    }

    try {
      info('📤 发送消息: ${message.content}');

      // 创建Completer来等待回调完成
      final completer = Completer<ChatMessage?>();

      await _imClient.sendTextMessage(
        message.toUserId,
        message.content,
        callback: (success, {clientMsgId, serverMsgId, errorMsg}) {
          if (success) {
            info('✅ 消息已发送: clientMsgId=$clientMsgId, serverMsgId=$serverMsgId');

            // ✅ 用SDK返回的clientMsgId更新message对象
            final updatedMessage = message.copyWith(
              clientMsgId: clientMsgId ?? '',
              msgId: serverMsgId ?? '',
            );

            // 触发消息状态变化事件（发送中）
            AppEvent.onMessageStatusChanged.add(
              MessageStatusChangedModel(
                messageId: clientMsgId ?? '',
                messageStatus: MessageStatus.sending,
              ),
            );

            // ✅ 触发会话更新事件（显示自己发送的最新消息）
            final currentUserId = _appData.user.value.id;
            final conversation = Conversation(
              name: message.toUserId,
              headImage: 'assets/other_headImage.png',
              lastMessage: _formatLastMessage(updatedMessage),
              timestamp: updatedMessage.timestamp.toString().substring(11, 16),
              userId: currentUserId,
              unreadCount: 0, // 自己发送的消息不算未读
              targetUserId: message.toUserId,
              targetUserName: message.toUserId,
              targetUserAvatar: 'assets/other_headImage.png',
              lastMsgFormat: MessageType.fromCode(updatedMessage.type),
              lastMsgId: clientMsgId ?? '',
              lastMsgTime: updatedMessage.timestamp.millisecondsSinceEpoch,
              chatId: message.chatId,
            );

            AppEvent.onConversationUpdated.add(conversation);
            info('✅ 已触发会话更新事件: ${updatedMessage.content}');

            completer.complete(updatedMessage);
          } else {
            error('❌ 消息发送失败: $errorMsg');
            completer.complete(null);
          }
        },
      );

      // 等待回调完成并返回更新后的消息
      return await completer.future;
    } catch (e) {
      error('❌ 发送消息异常: $e');
      return null;
    }
  }

  /// 发送已读确认
  void sendReadAck(String clientMsgId, String serverMsgId, String fromUserId, String toUserId) {
    if (!_imClient.isConnected) {
      error('未连接到IM服务器，无法发送已读确认');
      return;
    }

    // ✅ 去重：检查这条消息是否已经发送过ACK
    final ackKey = '${clientMsgId}_${serverMsgId}';
    if (_sentAckMessages.contains(ackKey)) {
      info('⚠️ 消息已发送过ACK，跳过: clientMsgId=$clientMsgId, msgId=$serverMsgId');
      return;
    }

    // ✅ 检查serverMsgId是否为空（如果为空说明消息还未被服务器确认，不应该发送ACK）
    if (serverMsgId.isEmpty) {
      info('⚠️ 消息还未被服务器确认（msgId为空），跳过ACK: clientMsgId=$clientMsgId');
      return;
    }

    info('👁️ 发送已读确认: clientMsgId=$clientMsgId, msgId=$serverMsgId');

    // 记录已发送ACK的消息
    _sentAckMessages.add(ackKey);

    _imClient.sendReadAck(clientMsgId, serverMsgId, fromUserId, toUserId);
  }

  /// 撤回消息
  void withdrawMessage(String msgId, String fromUserId, String toUserId) {
    if (!_imClient.isConnected) {
      error('未连接到IM服务器，无法撤回消息');
      return;
    }

    info('🗑️ 撤回消息: $msgId');
    _imClient.withdrawMessage(msgId, fromUserId, toUserId);
  }

  // ==================== 会话和消息查询 ====================

  /// 获取所有会话
  ///
  /// 返回会话列表，包含最后一条消息、未读数等信息
  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      return await _imClient.getConversations();
    } catch (e) {
      error('❌ 获取会话列表失败: $e');
      return [];
    }
  }

  /// 获取与指定用户的消息记录
  ///
  /// [targetUserId] 目标用户ID
  /// [limit] 每次加载的消息数量，默认50条
  /// [offset] 偏移量，用于分页加载
  Future<List<ChatMessage>> getMessages(
    String targetUserId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final sdkMessages = await _imClient.getMessages(
        targetUserId,
        limit: limit,
        offset: offset,
      );

      // 转换为ChatMessage
      return sdkMessages.map((sdkMsg) => ChatMessage(
        clientMsgId: sdkMsg.clientMsgId,
        msgId: sdkMsg.msgId,
        fromUserId: sdkMsg.fromUserId,
        toUserId: sdkMsg.toUserId,
        content: sdkMsg.content,
        type: sdkMsg.type,
        timestamp: sdkMsg.timestamp,
        status: _convertMessageStatus(sdkMsg.status),
        chatId: sdkMsg.chatId,
      )).toList();
    } catch (e) {
      error('❌ 获取消息记录失败: $e');
      return [];
    }
  }

  /// 更新会话未读数
  ///
  /// [targetUserId] 目标用户ID
  /// [unreadCount] 未读消息数
  Future<void> updateConversationUnreadCount(
    String targetUserId,
    int unreadCount,
  ) async {
    try {
      await _imClient.updateConversationUnreadCount(targetUserId, unreadCount);
    } catch (e) {
      error('❌ 更新会话未读数失败: $e');
    }
  }

  /// 清空当前用户的所有数据
  ///
  /// 用于用户退出登录时清理本地数据
  Future<void> clearUserData() async {
    try {
      await _imClient.clearUserData();
      info('🗑️ 用户数据已清空');
    } catch (e) {
      error('❌ 清空用户数据失败: $e');
    }
  }

  // ==================== 好友管理 ====================

  /// 获取好友列表
  Future<List<Map<String, dynamic>>> getFriendList() async {
    try {
      final friends = await _imClient.getFriendList();
      info('👥 获取到 ${friends.length} 个好友');
      return friends.map((user) => {
        'userId': user.id,
        'username': user.username,
        'nickname': user.nickname,
        'avatar': user.avatar ?? '',
      }).toList();
    } catch (e) {
      error('❌ 获取好友列表失败: $e');
      return [];
    }
  }

  /// 搜索用户
  Future<List<Map<String, dynamic>>> searchUser(String keyword) async {
    try {
      final users = await _imClient.searchUser(keyword);
      info('🔍 搜索到 ${users.length} 个用户');
      return users.map((user) => {
        'userId': user.id,
        'username': user.username,
        'nickname': user.nickname,
        'avatar': user.avatar ?? '',
      }).toList();
    } catch (e) {
      error('❌ 搜索用户失败: $e');
      return [];
    }
  }

  /// 发送好友请求
  Future<bool> sendFriendRequest(String toUserId, String requestMessage) async {
    try {
      final result = await _imClient.sendFriendRequest(toUserId, requestMessage);
      if (result) {
        info('✅ 好友请求已发送');
      } else {
        error('❌ 好友请求发送失败');
      }
      return result;
    } catch (e) {
      error('❌ 发送好友请求异常: $e');
      return false;
    }
  }

  /// 获取好友请求列表
  Future<List<Map<String, dynamic>>> getFriendRequestList() async {
    try {
      final requests = await _imClient.getFriendRequestList();
      info('📬 获取到 ${requests.length} 个好友请求');
      return requests;
    } catch (e) {
      error('❌ 获取好友请求列表失败: $e');
      return [];
    }
  }

  /// 处理好友请求
  Future<bool> handleFriendRequest(String requestId, bool accept) async {
    try {
      final result = await _imClient.handleFriendRequest(requestId, accept);
      if (result) {
        info('✅ 好友请求已处理');
      } else {
        error('❌ 处理好友请求失败');
      }
      return result;
    } catch (e) {
      error('❌ 处理好友请求异常: $e');
      return false;
    }
  }

  /// 删除好友
  Future<bool> deleteFriend(String friendUserId) async {
    try {
      final result = await _imClient.deleteFriend(friendUserId);
      if (result) {
        info('✅ 好友已删除');
      } else {
        error('❌ 删除好友失败');
      }
      return result;
    } catch (e) {
      error('❌ 删除好友异常: $e');
      return false;
    }
  }

  /// 从服务器拉取消息历史（离线消息）
  Future<List<ChatMessage>> fetchMessagesFromServer(
    String targetUserId, {
    int limit = 50,
  }) async {
    try {
      final sdkMessages = await _imClient.fetchMessagesFromServer(
        targetUserId,
        limit: limit,
      );

      // 转换为ChatMessage
      return sdkMessages.map((sdkMsg) => ChatMessage(
        clientMsgId: sdkMsg.clientMsgId,
        msgId: sdkMsg.msgId,
        fromUserId: sdkMsg.fromUserId,
        toUserId: sdkMsg.toUserId,
        content: sdkMsg.content,
        type: sdkMsg.type,
        timestamp: sdkMsg.timestamp,
        status: _convertMessageStatus(sdkMsg.status),
        chatId: sdkMsg.chatId,
      )).toList();
    } catch (e) {
      error('❌ 拉取消息失败: $e');
      return [];
    }
  }

  /// 设置应用是否在后台
  void setAppInBackground(bool inBackground) {
    _isAppInBackground = inBackground;
    info('📱 应用${inBackground ? "进入后台" : "回到前台"}');
  }

  /// 处理连接状态变化
  void _handleConnectionStatusChange(XZLLConnectionStatus status) {
    WebSocketStatus? wsStatus;

    switch (status) {
      case XZLLConnectionStatus.disconnected:
        wsStatus = WebSocketStatus.disconnected;
        break;
      case XZLLConnectionStatus.connecting:
        wsStatus = WebSocketStatus.connecting;
        break;
      case XZLLConnectionStatus.connected:
        wsStatus = WebSocketStatus.connected;
        break;
      case XZLLConnectionStatus.reconnecting:
        wsStatus = WebSocketStatus.reconnecting;
        break;
    }

    if (wsStatus != null) {
      AppEvent.webSocketStatus.add(wsStatus);
      info('🔄 连接状态更新: ${wsStatus.name}');
    }
  }

  /// 处理接收到的消息
  void _onMessageReceived(XZLLIMMessage sdkMessage) {
    try {
      info('📨 收到SDK消息: ${sdkMessage.content}');

      // 转换为ChatMessage
      final chatMessage = ChatMessage(
        clientMsgId: sdkMessage.clientMsgId,
        msgId: sdkMessage.msgId,
        fromUserId: sdkMessage.fromUserId,
        toUserId: sdkMessage.toUserId,
        content: sdkMessage.content,
        type: sdkMessage.type,
        timestamp: sdkMessage.timestamp,
        status: _convertMessageStatus(sdkMessage.status),
        chatId: sdkMessage.chatId,
      );

      // 触发消息接收事件
      AppEvent.onMessageReceived.add(chatMessage);

      // 更新会话列表
      _updateConversationOnNewMessage(chatMessage);
    } catch (e) {
      error('❌ 处理接收消息失败: $e');
    }
  }

  /// 处理消息状态变化
  void _onMessageStatusChanged(String messageId, int status) {
    try {
      info('✓ 消息状态变化: $messageId -> $status');

      // 转换状态
      MessageStatus messageStatus;
      if (status == 1) {
        messageStatus = MessageStatus.serverReceived;
      } else if (status == 4) {
        messageStatus = MessageStatus.readed;
      } else if (status == 5) {
        messageStatus = MessageStatus.withdraw;
      } else {
        messageStatus = MessageStatus.unRead;
      }

      // 触发状态变化事件
      AppEvent.onMessageStatusChanged.add(
        MessageStatusChangedModel(
          messageId: messageId,
          messageStatus: messageStatus,
        ),
      );

      // 添加到流中
      _messageStatusController.add({
        'messageId': messageId,
        'status': status,
      });
    } catch (e) {
      error('❌ 处理消息状态变化失败: $e');
    }
  }

  /// 更新会话列表（收到新消息时）
  void _updateConversationOnNewMessage(ChatMessage message) {
    try {
      info('📋 更新会话列表 - 收到新消息');

      final currentUserId = _appData.user.value.id;
      final targetUserId = message.fromUserId;

      // 计算未读数
      final messageChatId = message.chatId;
      final currentOpenChatId = AppEvent.currentOpenChatId.value;
      final isChatOpen = messageChatId == currentOpenChatId && currentOpenChatId.isNotEmpty;
      final unreadCount = isChatOpen ? 0 : 1;

      final conversation = Conversation(
        name: targetUserId,
        headImage: 'assets/other_headImage.png',
        lastMessage: _formatLastMessage(message),
        timestamp: message.timestamp.toString().substring(11, 16),
        userId: currentUserId,
        unreadCount: unreadCount,
        targetUserId: targetUserId,
        targetUserName: targetUserId,
        targetUserAvatar: 'assets/other_headImage.png',
        lastMsgFormat: MessageType.fromCode(message.type),
        lastMsgId: message.msgId,
        lastMsgTime: message.timestamp.millisecondsSinceEpoch,
        chatId: message.chatId,
      );

      AppEvent.onConversationUpdated.add(conversation);
    } catch (e) {
      error('❌ 更新会话列表失败: $e');
    }
  }

  /// 转换消息状态
  MessageStatus _convertMessageStatus(XZLLMessageStatus sdkStatus) {
    switch (sdkStatus) {
      case XZLLMessageStatus.sending:
        return MessageStatus.sending;
      case XZLLMessageStatus.serverReceived:
        return MessageStatus.serverReceived;
      case XZLLMessageStatus.unRead:
        return MessageStatus.unRead;
      case XZLLMessageStatus.readed:
        return MessageStatus.readed;
      case XZLLMessageStatus.withdraw:
        return MessageStatus.withdraw;
      case XZLLMessageStatus.sendFailed:
        return MessageStatus.fail;
    }
  }

  /// 格式化最后消息
  String _formatLastMessage(ChatMessage message) {
    if (message.content.length > 20) {
      return '${message.content.substring(0, 20)}...';
    }
    return message.content;
  }

  @override
  void onClose() {
    _imClient.dispose();
    _messageStatusController.close();
    super.onClose();
  }
}
