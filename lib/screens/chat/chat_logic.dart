import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/domain/message_status_changed_model.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';
import 'package:xzll_im_flutter_client/services/websocket_service.dart';
import 'package:xzll_im_flutter_client/services/data_base_service.dart';
import 'package:xzll_im_flutter_client/services/chat_history_service.dart';
import 'package:xzll_im_flutter_client/utils/chat_id_utils.dart';

class ChatLogic extends GetxController {
  /// 当前会话
  late Conversation conversation;
  
  /// WebSocket服务
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final AppData _appData = Get.find<AppData>();
  
  /// 数据库服务
  final DataBaseService _databaseService = Get.find<DataBaseService>();
  
  /// 历史消息服务
  final ChatHistoryService _historyService = ChatHistoryService();
  
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
  
  /// 事件流订阅
  StreamSubscription? _messageStatusSubscription;
  StreamSubscription? _newMessageSubscription;

  @override
  void onInit() {
    super.onInit();
    // 从路由参数中获取会话对象
    conversation = Get.arguments as Conversation;
    
    // ✅ 设置当前打开的会话ID（用于上下文感知的ACK）
    final currentUserId = _appData.user.value.id;
    final targetUserId = conversation.targetUserId ?? '';
    if (currentUserId.isNotEmpty && targetUserId.isNotEmpty) {
      final chatId = conversation.chatId ?? ChatIdUtils.generateC2CChatId(currentUserId, targetUserId);
      AppEvent.currentOpenChatId.add(chatId);
      info("🔓 设置当前打开会话: $chatId");
    }
    
    // ✅ 优化：不在聊天界面重复初始化WebSocket
    // WebSocket 应该在应用启动时初始化，这里只需确保已连接
    _ensureWebSocketConnected();
    _setupMessageListeners();
    
    // 加载历史消息
    _loadHistoryMessages();
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
      await _webSocketService.initWebSocket();
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
        
        // ✅ 同步更新数据库中的消息状态（双轨制：优先使用clientMsgId）
        try {
          await _databaseService.updateMessageStatus(
            updatedMessage.clientMsgId, 
            statusModel.messageStatus,
            serverMsgId: statusModel.serverMsgId
          );
          info("💾 消息状态已同步到数据库: ${statusModel.messageStatus.desc}");
        } catch (e) {
          error("❌ 同步消息状态到数据库失败: $e");
        }
        
        // 如果是首次收到服务端确认且有完整消息数据，则保存完整消息记录
        if (statusModel.messageStatus == MessageStatus.serverReceived && 
            updatedMessage.msgId.isNotEmpty && 
            updatedMessage.clientMsgId.isNotEmpty) {
          info("💾 消息已被服务器确认，保存完整消息记录到数据库");
          _saveMessageToDatabase(updatedMessage);
        }
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
        messages.add(message);
        _scrollToBottom();
        
        // 保存接收到的消息到本地数据库
        _saveMessageToDatabase(message);
        
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

      // 创建消息对象（双轨制：WebSocketService会生成clientMsgId，服务端会分配真实的msgId）
      final message = ChatMessage(
        clientMsgId: '', // 空值，WebSocketService会生成UUID作为clientMsgId
        msgId: '', // 空值，服务端会分配真实的msgId（雪花算法）
        content: content,
        fromUserId: currentUserId,
        toUserId: targetUserId,
        type: 1, // 文本消息
        status: MessageStatus.sending, // 发送中状态
        timestamp: DateTime.now(),
        chatId: chatId,
      );

      // ✅ 发送到服务器并获取更新后的消息对象（包含clientMsgId）
      ChatMessage? sentMessage = await _webSocketService.sendMessage(message);

      if (sentMessage == null) {
        error("❌ 发送消息失败 - WebSocketService.sendMessage 返回 null");
        // 添加失败状态的消息到本地列表
        final failedMessage = message.copyWith(status: MessageStatus.fail);
        messages.add(failedMessage);
        info("➕ 添加失败消息到界面: clientMsgId=${failedMessage.clientMsgId}, msgId=${failedMessage.msgId}, status=${failedMessage.status.desc}");
        Get.snackbar('发送失败', '消息发送失败，请重试', snackPosition: SnackPosition.TOP);
      } else {
        info("✅ 消息已发送到服务端，等待服务端分配真实ID并确认");
        info("📋 返回的消息: clientMsgId=${sentMessage.clientMsgId}, msgId=${sentMessage.msgId}, status=${sentMessage.status.desc}");
        
        // ✅ 添加发送中状态的消息到本地列表（使用WebSocketService返回的完整消息对象）
        messages.add(sentMessage);
        info("➕ 添加发送中消息到界面: clientMsgId=${sentMessage.clientMsgId}, msgId=${sentMessage.msgId}, status=${sentMessage.status.desc}");
        
        // 暂时不保存到数据库，等收到服务端确认和真实ID后再保存
        // _saveMessageToDatabase(sentMessage);
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
      
      // 1. 首先从本地数据库加载历史消息
      final localMessages = await _databaseService.getMessagesBetweenUsers(
        currentUserId,
        targetUserId,
        limit: 50,
      );
      
      if (localMessages.isNotEmpty) {
        info('✅ 从本地加载 ${localMessages.length} 条历史消息');
        // 将历史消息添加到消息列表（注意：数据库返回的是倒序，需要反转）
        messages.assignAll(localMessages.reversed.toList());
        _scrollToBottom();
        
        // ✅ 标记加载的历史消息中的未读消息为已读
        _markHistoryMessagesAsRead();
      } else {
        info('💭 本地没有历史消息，尝试从服务端获取...');
        // 2. 如果本地没有消息，从服务端获取
        await _loadHistoryFromServer();
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
        
        _webSocketService.sendReadAck(
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
    
    // 检查WebSocket连接状态
    _webSocketService.checkConnectionStatus();
    
    info('🔍 =====================================');
  }

  /// 从服务端加载历史消息
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
          
          // 保存到本地数据库
          await _databaseService.insertMessages(serverMessages);
          
          if (lastMsgId == null) {
            // 首次加载，直接设置消息列表
            messages.assignAll(serverMessages);
            _scrollToBottom();
            
            // ✅ 标记从服务端加载的历史消息中的未读消息为已读
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

  /// 保存消息到本地数据库
  Future<void> _saveMessageToDatabase(ChatMessage message) async {
    try {
      await _databaseService.insertMessage(message);
      
      // 同时更新会话信息
      final updatedConversation = conversation.copyWith(
        lastMessage: message.content,
        lastMsgId: message.msgId,
        lastMsgTime: message.timestamp.millisecondsSinceEpoch,
        timestamp: _formatMessageTime(message.timestamp),
      );
      
      await _databaseService.insertOrUpdateConversation(updatedConversation);
      
      info('💾 消息已保存到本地数据库: ${message.msgId}');
    } catch (e) {
      error('❌ 保存消息到数据库失败: $e');
    }
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

  @override
  void onClose() {
    // ✅ 清空当前打开的会话ID
    AppEvent.currentOpenChatId.add('');
    info("🔒 清空当前打开会话");
    
    textController.dispose();
    scrollController.dispose();
    
    // 清理事件订阅
    _messageStatusSubscription?.cancel();
    _newMessageSubscription?.cancel();
    
    super.onClose();
  }
}
