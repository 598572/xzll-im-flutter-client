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
import 'package:xzll_im_flutter_client/services/websocket_service.dart';
import 'package:xzll_im_flutter_client/services/data_base_service.dart';
import 'package:xzll_im_flutter_client/services/chat_history_service.dart';

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
    
    // 初始化WebSocket连接和监听器
    _initializeWebSocket();
    _setupMessageListeners();
    
    // 加载历史消息
    _loadHistoryMessages();
  }

  /// 初始化WebSocket连接
  Future<void> _initializeWebSocket() async {
    if (!_appData.isLoggedIn) {
      error('❌ 用户未登录，无法连接WebSocket');
      return;
    }

    info("🔗 开始连接WebSocket...");
    await _webSocketService.initWebSocket();
  }

  /// 设置消息监听器
  void _setupMessageListeners() {
    // 监听消息状态变化
    _messageStatusSubscription = AppEvent.onMessageStatusChanged.stream.listen((MessageStatusChangedModel statusModel) {
      info("📊 消息状态更新: ${statusModel.messageId} -> ${statusModel.messageStatus.desc}");
      
      final index = messages.indexWhere((m) => m.msgId == statusModel.messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(status: statusModel.messageStatus);
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
        
        // 发送接收确认
        _webSocketService.sendReceivedAck(
          message.msgId,
          message.fromUserId,
          message.toUserId,
          message.chatId,
        );
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

      // 获取聊天ID（使用两个用户ID的组合）
      final currentUserId = _appData.user.value.id;
      final targetUserId = conversation.targetUserId!;
      final chatId = _generateChatId(currentUserId, targetUserId);

      // 创建消息对象（让WebSocketService内部处理消息ID）
      final message = ChatMessage(
        msgId: '', // 这里先给个空值，WebSocketService会设置真实的msgId
        content: content,
        fromUserId: currentUserId,
        toUserId: targetUserId,
        type: 1, // 文本消息
        status: MessageStatus.sending, // 发送中状态
        timestamp: DateTime.now(),
        chatId: chatId,
      );

      // 发送到服务器并获取更新后的消息对象（包含真实的msgId）
      ChatMessage? sentMessage = await _webSocketService.sendMessage(message);

      if (sentMessage == null) {
        error("❌ 发送消息失败");
        // 添加失败状态的消息到本地列表
        messages.add(message.copyWith(status: MessageStatus.fail));
        Get.snackbar('发送失败', '消息发送失败，请重试', snackPosition: SnackPosition.TOP);
      } else {
        info("✅ 消息发送成功，等待服务器确认");
        // 添加发送中状态的消息到本地列表（使用返回的消息对象，包含真实msgId）
        messages.add(sentMessage);
        
        // 保存消息到本地数据库
        _saveMessageToDatabase(sentMessage);
      }
      
      _scrollToBottom();
    } catch (e) {
      error("❌ 发送消息异常: $e");
      Get.snackbar('发送失败', '发送消息时出现异常', snackPosition: SnackPosition.TOP);
    } finally {
      isSending.value = false;
    }
  }

  /// 生成聊天ID
  String _generateChatId(String userId1, String userId2) {
    // 按字典序排列，确保两个用户之间的聊天ID唯一
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
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
      // 移除失败的消息
      messages.removeWhere((m) => m.msgId == message.msgId);
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
      } else {
        info('💭 本地没有历史消息，尝试从服务端获取...');
        // 2. 如果本地没有消息，从服务端获取
        await _loadHistoryFromServer();
      }
    } catch (e) {
      error('❌ 加载历史消息失败: $e');
    }
  }

  /// 从服务端加载历史消息
  Future<void> _loadHistoryFromServer({String? lastMsgId}) async {
    try {
      final currentUserId = _appData.user.value.id;
      final targetUserId = conversation.targetUserId!;
      
      // 生成聊天ID
      final chatId = _historyService.generateChatId(currentUserId, targetUserId);
      
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
    textController.dispose();
    scrollController.dispose();
    
    // 清理事件订阅
    _messageStatusSubscription?.cancel();
    _newMessageSubscription?.cancel();
    
    super.onClose();
  }
}
