import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/api/user_api.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/domain/message_status_changed_model.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';
import 'package:xzll_im_flutter_client/screens/conversation/conversation_logic.dart';
import 'package:xzll_im_flutter_client/services/imsdk_manager.dart';
import 'package:xzll_im_flutter_client/services/chat_history_service.dart';
import 'package:xzll_im_flutter_client/services/user_info_service.dart';
import 'package:xzll_im_flutter_client/models/user_info.dart';
import 'package:xzll_im_sdk/xzll_im_sdk.dart';

class ChatLogic extends GetxController {
  /// 当前会话
  late Conversation conversation;

  /// IM SDK管理器
  final IMSDKManager _imSdkManager = Get.find<IMSDKManager>();
  final AppData _appData = Get.find<AppData>();

  /// 历史消息服务
  final ChatHistoryService _historyService = ChatHistoryService();

  /// ✅ 会话管理器（自动处理会话状态）
  ChatSessionManager? _sessionManager;

  /// 暴露appData供视图使用
  AppData get appData => _appData;
  
  /// 文本输入控制器
  final TextEditingController textController = TextEditingController();
  
  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  
  /// 响应式消息列表
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  
  /// 发送中状态
  final RxBool isSending = false.obs;
  
  /// 对方用户信息（用于显示头像和昵称）
  final Rx<UserInfo?> targetUserInfo = Rx<UserInfo?>(null);
  
  /// 事件流订阅
  StreamSubscription? _messageStatusSubscription;
  StreamSubscription? _newMessageSubscription;
  
  /// 键盘观察者
  _KeyboardObserver? _keyboardObserver;

  @override
  void onInit() {
    super.onInit();
    // 从路由参数中获取会话对象
    conversation = Get.arguments as Conversation;
    
    // ✅ 监听软键盘变化，自动滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupKeyboardListener();
    });
    
    // ✅ 设置当前打开的会话ID（用于上下文感知的ACK）
    final currentUserId = _appData.user.value.id;
    final targetUserId = conversation.targetUserId ?? '';
    if (currentUserId.isNotEmpty && targetUserId.isNotEmpty) {
      final chatId = conversation.chatId ?? ChatIdUtils.generateC2CChatId(currentUserId, targetUserId);
      AppEvent.currentOpenChatId.add(chatId);
      info("🔓 设置当前打开会话: $chatId");

      // ✅ 使用SDK的会话管理器（自动处理会话状态）
      _sessionManager = _imSdkManager.openChatSession(chatId);

      // ✅ 清零该会话的未读数（延迟到下一个事件循环，避免在build期间修改状态）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final conversationLogic = Get.find<ConversationLogic>();
          conversationLogic.clearUnreadCount(chatId);
        } catch (e) {
          info("⚠️ 无法清零未读数，ConversationLogic未找到: $e");
        }
      });
    }
    
    // ✅ 优化：不在聊天界面重复初始化WebSocket
    // WebSocket 应该在应用启动时初始化，这里只需确保已连接
    _ensureWebSocketConnected();
    _setupMessageListeners();
    
    // 加载历史消息
    _loadHistoryMessages();
    
    // ✅ 检查是否需要从服务器同步消息
    _checkAndSyncMessages();
    
    // ✅ 获取对方用户信息（用于显示头像和昵称）
    _loadTargetUserInfo();
  }

  /// 确保WebSocket已连接（不重复初始化）
  Future<void> _ensureWebSocketConnected() async {
    if (!_appData.isLoggedIn) {
      error('❌ 用户未登录，无法使用WebSocket');
      return;
    }

    // ✅ 只检查连接状态，不重复初始化
    if (AppEvent.webSocketStatus.value != WebSocketStatus.connected) {
      info("⚠️ WebSocket未连接，尝试初始化...");
      await _imSdkManager.connect();
    } else {
      info("✅ WebSocket已连接，可以正常使用");
    }
  }

  /// 设置消息监听器
  void _setupMessageListeners() {
    // 监听消息状态变化
    _messageStatusSubscription = AppEvent.onMessageStatusChanged.stream.listen((MessageStatusChangedModel statusModel) async {
      info("📊 收到消息状态更新: ${statusModel.messageId} -> ${statusModel.messageStatus.desc}");
      
      // ✅ 双轨制查找：优先使用clientMsgId查找，其次使用msgId（serverMsgId）
      int index = messages.indexWhere((m) => m.clientMsgId == statusModel.messageId);
      if (index == -1) {
        // 如果clientMsgId未找到，尝试使用msgId查找（适用于撤回等场景）
        index = messages.indexWhere((m) => m.msgId == statusModel.messageId);
      }
      
      if (index != -1) {
        final oldStatus = messages[index].status;
        final oldMessage = messages[index];

        // 更新消息状态，如果有serverMsgId则同时更新
        ChatMessage updatedMessage = oldMessage.copyWith(
          status: statusModel.messageStatus,
          msgId: statusModel.serverMsgId?.isNotEmpty == true ? statusModel.serverMsgId : oldMessage.msgId,
        );

        messages[index] = updatedMessage;
        info("✅ 状态更新成功: 位置[$index] ${oldStatus.desc} -> ${statusModel.messageStatus.desc}");
        info("   clientMsgId: ${updatedMessage.clientMsgId}");
        info("   msgId: ${updatedMessage.msgId}");

        // ✅ SDK自动处理数据库状态更新，无需手动操作
      } else {
        waring("⚠️ 未找到要更新状态的消息: ${statusModel.messageId}");
        info("📱 当前消息列表:");
        for (int i = 0; i < messages.length; i++) {
          info("   [$i] clientMsgId: ${messages[i].clientMsgId}, msgId: ${messages[i].msgId}, status: ${messages[i].status.desc}");
        }
      }
    });

    // 监听接收到的新消息
    _newMessageSubscription = AppEvent.onMessageReceived.stream.listen((ChatMessage message) {
      info("📨 收到新消息: ${message.content} from: ${message.fromUserId}");

      // 只显示与当前会话相关的消息
      if (message.fromUserId == conversation.targetUserId ||
          message.toUserId == conversation.targetUserId) {

        // ✅ 去重检查：避免重复添加同一消息
        bool isDuplicate = messages.any((m) =>
          (m.clientMsgId.isNotEmpty && m.clientMsgId == message.clientMsgId) ||
          (m.msgId.isNotEmpty && m.msgId == message.msgId)
        );

        if (isDuplicate) {
          waring("⚠️ 重复消息，已忽略 - clientMsgId: ${message.clientMsgId}, msgId: ${message.msgId}");
          return;
        }

        messages.add(message);
        _scrollToBottom();

        // ✅ SDK自动处理消息保存，无需手动操作

        // ✅ 由于采用了"上下文感知ACK"，WebSocketService 已根据会话打开状态自动发送了正确的ACK
        // 会话打开时→直接发送已读ACK（status=4）
        // 会话未打开时→发送未读ACK（status=3）
        // 因此这里不需要再次发送ACK
        info("✅ WebSocketService已根据会话状态自动发送ACK，无需重复发送");
      }
    });
  }

  /// 发送文本消息
  Future<void> sendTextMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (isSending.value) return;

    try {
      isSending.value = true;
      info("📤 准备发送消息: $content");

      // 获取聊天ID（优先使用从服务端返回的chatId）
      final currentUserId = _appData.user.value.id;
      final targetUserId = conversation.targetUserId!;
      final chatId = conversation.chatId ?? ChatIdUtils.generateC2CChatId(currentUserId, targetUserId);

      // 创建消息对象（使用SDK发送消息）
      final message = ChatMessage(
        clientMsgId: '', // SDK会生成UUID作为clientMsgId
        msgId: '', // 空值，服务端会分配真实的msgId（雪花算法）
        content: content,
        fromUserId: currentUserId,
        toUserId: targetUserId,
        type: 1, // 文本消息
        status: MessageStatus.sending, // 发送中状态
        timestamp: DateTime.now(),
        chatId: chatId,
      );

      // ✅ 通过SDK发送到服务器并获取更新后的消息对象（包含clientMsgId）
      ChatMessage? sentMessage = await _imSdkManager.sendMessage(message);

      if (sentMessage == null) {
        error("❌ 发送消息失败 - IMSDKManager.sendMessage 返回 null");
        // 添加失败状态的消息到本地列表
        final failedMessage = message.copyWith(status: MessageStatus.fail);
        messages.add(failedMessage);
        info("➕ 添加失败消息到界面: clientMsgId=${failedMessage.clientMsgId}, msgId=${failedMessage.msgId}, status=${failedMessage.status.desc}");
        Get.snackbar('发送失败', '消息发送失败，请重试', snackPosition: SnackPosition.TOP);
      } else {
        info("✅ 消息已发送到服务端，等待服务端分配真实ID并确认");
        info("📋 返回的消息: clientMsgId=${sentMessage.clientMsgId}, msgId=${sentMessage.msgId}, status=${sentMessage.status.desc}");

        // ✅ 添加发送中状态的消息到本地列表（使用SDK返回的完整消息对象）
        messages.add(sentMessage);
        info("➕ 添加发送中消息到界面: clientMsgId=${sentMessage.clientMsgId}, msgId=${sentMessage.msgId}, status=${sentMessage.status.desc}");

        // ✅ SDK自动处理消息保存，无需手动操作
      }

      _scrollToBottom();
    } catch (e) {
      error("❌ 发送消息异常: $e");
      Get.snackbar('发送失败', '发送消息时出现异常', snackPosition: SnackPosition.TOP);
    } finally {
      isSending.value = false;
    }
  }


  /// 滚动到底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 重试发送失败的消息
  void retryMessage(ChatMessage message) {
    if (message.status == MessageStatus.fail) {
      sendTextMessage(message.content);
      // ✅ 使用双轨制ID移除失败的消息（优先使用clientMsgId）
      messages.removeWhere((m) => 
        (message.clientMsgId.isNotEmpty && m.clientMsgId == message.clientMsgId) ||
        (message.clientMsgId.isEmpty && m.msgId == message.msgId)
      );
    }
  }

  /// 从本地数据库和服务端加载历史消息
  Future<void> _loadHistoryMessages() async {
    try {
      info('📚 开始加载历史消息...');

      final currentUserId = _appData.user.value.id;
      final targetUserId = conversation.targetUserId;

      if (targetUserId == null || targetUserId.isEmpty) {
        error('❌ 目标用户ID为空，无法加载历史消息');
        return;
      }

      // 打印调试信息
      _debugChatInfo();

      // 1. 首先从SDK数据库加载历史消息
      final localMessages = await _imSdkManager.getMessages(
        targetUserId,
        limit: 50,
      );

      if (localMessages.isNotEmpty) {
        info('✅ 从本地加载 ${localMessages.length} 条历史消息');
        // 将历史消息添加到消息列表
        messages.assignAll(localMessages);
        _scrollToBottom();

        // ✅ 恢复：对历史未读消息发送已读ACK（上下文感知ACK只对新消息生效）
        _markHistoryMessagesAsRead();
      } else {
        info('💭 本地没有历史消息，尝试从服务端获取...');
        // 2. 如果本地没有消息，优先使用新的C2C历史接口获取
        await _loadC2CChatHistoryFromServer();
      }
    } catch (e) {
      error('❌ 加载历史消息失败: $e');
    }
  }
  
  /// 标记历史消息中的未读消息为已读
  void _markHistoryMessagesAsRead() {
    final currentUserId = _appData.user.value.id;

    info('👁️ 检查历史消息中的未读消息...');
    int unreadCount = 0;

    for (var message in messages) {
      // 只处理接收到的未读消息（不是自己发的）
      if (message.toUserId == currentUserId &&
          message.fromUserId != currentUserId &&
          message.status == MessageStatus.unRead) {

        unreadCount++;
        info('👁️ 发送已读确认 - clientMsgId: ${message.clientMsgId}, msgId: ${message.msgId}');

        _imSdkManager.sendReadAck(
          message.clientMsgId,
          message.msgId,
          message.fromUserId,
          message.toUserId,
        );
      }
    }

    if (unreadCount > 0) {
      info('✅ 已为 $unreadCount 条历史消息发送已读确认');
    } else {
      info('💡 没有未读的历史消息');
    }
  }
  
  /// 调试信息输出
  void _debugChatInfo() {
    info('🔍 ========== 聊天调试信息 ==========');
    info('🆔 当前用户ID: ${_appData.user.value.id}');
    info('🎯 目标用户ID: ${conversation.targetUserId}');
    info('💬 会话名称: ${conversation.targetUserName}');
    info('🔗 会话chatId: ${conversation.chatId}');
    info('📊 WebSocket状态: ${AppEvent.webSocketStatus.value}');
    info('📱 当前消息数量: ${messages.length}');

    // 检查IM SDK连接状态
    info('🔗 IM SDK连接状态: ${_imSdkManager.isInitialized ? "已初始化" : "未初始化"}');

    info('🔍 =====================================');
  }

  /// 从服务端加载C2C聊天历史记录（新接口，用于卸载重装后恢复聊天记录）
  Future<void> _loadC2CChatHistoryFromServer() async {
    try {
      final currentUserId = _appData.user.value.id;
      final targetUserId = conversation.targetUserId!;
      
      // 获取聊天ID（优先使用从服务端返回的chatId）
      final chatId = conversation.chatId ?? ChatIdUtils.generateC2CChatId(currentUserId, targetUserId);
      
      info('🌐 从服务端获取C2C聊天历史记录，chatId: $chatId');
      
      // 调用新的C2C历史接口
      final serverMessagesData = await UserApi.getC2CChatHistory(chatId: chatId);
      
      if (serverMessagesData.isNotEmpty) {
        info('✅ 从服务端获取 ${serverMessagesData.length} 条C2C聊天历史记录');
        
        // 将服务器消息数据转换为ChatMessage对象
        final chatMessages = <ChatMessage>[];
        for (final msgData in serverMessagesData) {
          final chatMessage = _convertC2CHistoryMessageToChatMessage(msgData, chatId);
          if (chatMessage != null) {
            chatMessages.add(chatMessage);
          }
        }
        
        // 按时间排序（最新的在后面）
        chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        if (chatMessages.isNotEmpty) {
          // ✅ SDK自动处理消息保存，无需手动操作

          // 设置消息列表
          messages.assignAll(chatMessages);
          _scrollToBottom();

          // ✅ 恢复：对历史未读消息发送已读ACK（上下文感知ACK只对新消息生效）
          _markHistoryMessagesAsRead();

          info('✅ 成功加载 ${chatMessages.length} 条C2C聊天历史记录');
        } else {
          info('💭 转换后的消息列表为空');
        }
      } else {
        info('💭 服务端没有返回C2C聊天历史记录，尝试使用旧接口...');
        // 如果新接口没有数据，尝试使用旧接口
        await _loadHistoryFromServer();
      }
    } catch (e) {
      error('❌ 从服务端加载C2C聊天历史记录异常: $e');
      // 如果新接口失败，尝试使用旧接口
      try {
        await _loadHistoryFromServer();
      } catch (e2) {
        error('❌ 使用旧接口加载历史消息也失败: $e2');
      }
    }
  }

  /// 将C2C历史接口返回的消息数据转换为ChatMessage对象
  ChatMessage? _convertC2CHistoryMessageToChatMessage(Map<String, dynamic> msgData, String chatId) {
    try {
      final msgId = msgData['msgId']?.toString() ?? '';
      final msgContent = msgData['msgContent']?.toString() ?? '';
      final fromUserId = msgData['fromUserId']?.toString() ?? '';
      final toUserId = msgData['toUserId']?.toString() ?? '';
      final msgFormat = msgData['msgFormat'] as int? ?? 1;
      final msgCreateTime = msgData['msgCreateTime'] as int? ?? 0;
      final msgStatus = msgData['msgStatus'] as int? ?? 4; // 默认已读
      final withdrawFlag = msgData['withdrawFlag'] as int? ?? 0;
      
      return ChatMessage(
        clientMsgId: msgId, // 历史消息没有clientMsgId，使用msgId作为clientMsgId
        msgId: msgId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        content: msgContent,
        timestamp: DateTime.fromMillisecondsSinceEpoch(msgCreateTime),
        type: msgFormat,
        status: _convertMsgStatusToMessageStatus(msgStatus),
        chatId: chatId,
        withdrawStatus: withdrawFlag == 1 
            ? MessageWithdrawStatus.yes 
            : MessageWithdrawStatus.no,
      );
    } catch (e) {
      error('❌ 转换C2C历史消息失败: $e, 消息数据: $msgData');
      return null;
    }
  }

  /// 从服务端加载历史消息（旧接口，作为备用）
  Future<void> _loadHistoryFromServer({String? lastMsgId}) async {
    try {
      final currentUserId = _appData.user.value.id;
      final targetUserId = conversation.targetUserId!;
      
      // 获取聊天ID（优先使用从服务端返回的chatId）
      final chatId = conversation.chatId ?? ChatIdUtils.generateC2CChatId(currentUserId, targetUserId);
      
      info('🌐 从服务端获取历史消息，chatId: $chatId, lastMsgId: $lastMsgId');
      
      final response = await _historyService.getChatHistory(
        chatId: chatId,
        lastMsgId: lastMsgId,
        pageSize: 50,
      );
      
      if (response.success && response.data != null) {
        final historyData = response.data!;
        final serverMessages = historyData.messages;
        
        if (serverMessages.isNotEmpty) {
          info('✅ 从服务端获取 ${serverMessages.length} 条历史消息');

          // ✅ SDK自动处理消息保存，无需手动操作

          if (lastMsgId == null) {
            // 首次加载，直接设置消息列表
            messages.assignAll(serverMessages);
            _scrollToBottom();

            // ✅ 恢复：对历史未读消息发送已读ACK（上下文感知ACK只对新消息生效）
            _markHistoryMessagesAsRead();
          } else {
            // 加载更多消息，插入到列表开头
            messages.insertAll(0, serverMessages);
          }
        } else {
          info('💭 服务端没有更多历史消息');
        }
      } else {
        error('❌ 从服务端获取历史消息失败: ${response.message}');
      }
    } catch (e) {
      error('❌ 从服务端加载历史消息异常: $e');
    }
  }

  /// 加载更多历史消息（上拉加载）
  Future<void> loadMoreHistoryMessages() async {
    if (messages.isEmpty) return;
    
    // 获取最早的消息ID作为分页参数
    final oldestMsgId = messages.first.msgId;
    info('🔄 加载更多历史消息，最早消息ID: $oldestMsgId');
    
    await _loadHistoryFromServer(lastMsgId: oldestMsgId);
  }

  /// 格式化消息时间为会话显示格式
  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
      return '星期${weekdays[dateTime.weekday - 1]}';
    } else if (dateTime.year == now.year) {
      return '${dateTime.month}月${dateTime.day}日';
    } else {
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    }
  }

  /// 设置软键盘监听器，当软键盘弹出时智能滚动
  void _setupKeyboardListener() {
    // 创建并添加键盘观察者
    _keyboardObserver = _KeyboardObserver(
      onKeyboardShow: () {
        // 软键盘弹出时，使用微任务立即响应，避免帧延迟
        scheduleMicrotask(() {
          scrollToShowLastMessage();
        });
      },
    );
    WidgetsBinding.instance.addObserver(_keyboardObserver!);
  }

  /// 智能滚动，确保最后一条消息可见但不会过度滚动
  void scrollToShowLastMessage() {
    if (scrollController.hasClients && messages.isNotEmpty) {
      // 计算合适的滚动位置，不要滚动到最底部，而是确保最后一条消息可见
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;
      
      // 如果当前已经接近底部，则适度滚动
      if (maxScroll - currentScroll < 200) {
        // ✅ 使用更高性能的滚动方式
        final targetPosition = maxScroll * 0.85;
        
        // 如果距离很近，直接跳转，避免动画卡顿
        if ((targetPosition - currentScroll).abs() < 100) {
          scrollController.jumpTo(targetPosition);
        } else {
          // 距离较远时使用快速动画
          scrollController.animateTo(
            targetPosition,
            duration: Duration(milliseconds: 120), // 进一步减少动画时间
            curve: Curves.easeOutQuart, // 使用更快的缓动曲线
          );
        }
      }
    }
  }

  /// 获取对方用户信息（用于显示头像和昵称）
  Future<void> _loadTargetUserInfo() async {
    final targetUserId = conversation.targetUserId;
    if (targetUserId == null || targetUserId.isEmpty) {
      info('⚠️ 无法获取对方用户信息，targetUserId为空');
      return;
    }

    try {
      info('🔍 获取对方用户信息: $targetUserId');
      
      // ✅ 使用缓存优先的策略获取用户信息
      final userInfoMap = await UserInfoService.batchGetUserInfo([targetUserId]);
      
      if (userInfoMap.containsKey(targetUserId)) {
        targetUserInfo.value = userInfoMap[targetUserId];
        info('✅ 成功获取对方用户信息: ${targetUserInfo.value?.userName}');
      } else {
        info('⚠️ 未找到对方用户信息: $targetUserId');
      }
    } catch (e) {
      error('❌ 获取对方用户信息失败: $e');
    }
  }

  /// 检查本地消息记录，如果为空则从服务器同步
  Future<void> _checkAndSyncMessages() async {
    try {
      // 如果本地已有消息记录，则不需要同步
      if (messages.isNotEmpty) {
        info('ℹ️ 本地已有 ${messages.length} 条消息，无需同步');
        return;
      }
      
      info('🔍 本地无消息记录，开始从服务器同步');
      await syncMessagesFromServer();
    } catch (e) {
      error('❌ 检查和同步消息失败: $e');
    }
  }

  /// 从服务器同步聊天记录（当本地没有消息记录时）
  Future<void> syncMessagesFromServer() async {
    try {
      info('🔄 开始同步服务器消息，chatId: ${conversation.chatId}');
      
      // 调用API获取服务器消息
      final serverMessages = await UserApi.getChatMessages(
        chatId: conversation.chatId ?? '',
        userId: appData.user.value.id,
        pageSize: 50, // 获取最近50条消息
      );
      
      if (serverMessages.isNotEmpty) {
        info('✅ 从服务器获取到 ${serverMessages.length} 条消息');
        
        // 将服务器消息转换为ChatMessage对象
        final chatMessages = <ChatMessage>[];
        for (final msgData in serverMessages) {
          final chatMessage = _convertServerMessageToChatMessage(msgData);
          if (chatMessage != null) {
            chatMessages.add(chatMessage);
          }
        }
        
        // 按时间排序（最新的在后面）
        chatMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // 更新消息列表
        messages.assignAll(chatMessages);

        // ✅ SDK自动处理消息保存，无需手动操作

        info('✅ 成功同步 ${chatMessages.length} 条消息到本地');
      } else {
        info('ℹ️ 服务器没有返回消息记录');
      }
    } catch (e) {
      error('❌ 同步服务器消息失败: $e');
    }
  }

  /// 将服务器消息数据转换为ChatMessage对象
  ChatMessage? _convertServerMessageToChatMessage(Map<String, dynamic> msgData) {
    try {
      final msgId = msgData['msgId']?.toString() ?? '';
      return ChatMessage(
        clientMsgId: msgId, // 使用服务器msgId作为clientMsgId
        msgId: msgId,
        fromUserId: msgData['fromUserId']?.toString() ?? '',
        toUserId: msgData['toUserId']?.toString() ?? '',
        content: msgData['msgContent']?.toString() ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(msgData['msgCreateTime'] as int? ?? 0),
        type: msgData['msgFormat'] as int? ?? 1,
        status: _convertMsgStatusToMessageStatus(msgData['msgStatus'] as int? ?? 1),
        chatId: msgData['chatId']?.toString() ?? '',
      );
    } catch (e) {
      error('❌ 转换服务器消息失败: $e, 消息数据: $msgData');
      return null;
    }
  }

  /// 将服务器的msgFormat转换为MessageType
  MessageType _convertMsgFormatToMessageType(int msgFormat) {
    switch (msgFormat) {
      case 1: // TEXT_MSG
        return MessageType.text;
      case 2: // VOICE_MSG
        return MessageType.voice;
      case 3: // LOCATION_MSG
        return MessageType.location;
      default:
        return MessageType.text;
    }
  }

  /// 将服务器的msgStatus转换为MessageStatus
  MessageStatus _convertMsgStatusToMessageStatus(int msgStatus) {
    switch (msgStatus) {
      case 1:
        return MessageStatus.serverReceived;
      case 2:
        return MessageStatus.offLine;
      case 3:
        return MessageStatus.unRead;
      case 4:
        return MessageStatus.readed;
      default:
        return MessageStatus.serverReceived;
    }
  }

  @override
  void onClose() {
    // ✅ 清空当前打开的会话ID（Flutter层）
    AppEvent.currentOpenChatId.add('');
    info("🔒 清空当前打开会话（Flutter层）");

    // ✅ 关闭会话管理器（自动清空SDK会话ID）
    _sessionManager?.close();
    _sessionManager = null;

    textController.dispose();
    scrollController.dispose();

    // 清理键盘观察者
    if (_keyboardObserver != null) {
      WidgetsBinding.instance.removeObserver(_keyboardObserver!);
    }

    // 清理事件订阅
    _messageStatusSubscription?.cancel();
    _newMessageSubscription?.cancel();

    super.onClose();
  }
}

/// 软键盘观察者，用于监听软键盘状态变化
class _KeyboardObserver extends WidgetsBindingObserver {
  final VoidCallback onKeyboardShow;
  double _lastBottomInset = 0;
  bool _isProcessing = false; // 防止重复处理

  _KeyboardObserver({required this.onKeyboardShow});

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    
    // 防止重复处理
    if (_isProcessing) return;
    
    // 获取软键盘高度
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    
    // 只在软键盘从隐藏变为显示时触发回调，避免重复触发
    if (bottomInset > 0 && _lastBottomInset == 0) {
      _isProcessing = true;
      onKeyboardShow();
      
      // 短暂延迟后重置处理标志
      Timer(Duration(milliseconds: 50), () {
        _isProcessing = false;
      });
    }
    
    _lastBottomInset = bottomInset;
  }
}
