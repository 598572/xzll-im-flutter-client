import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';
import 'package:xzll_im_flutter_client/models/domain/message_status_changed_model.dart';
import '../models/domain/chat_message.dart';
import '../models/domain/conversation.dart';
import '../models/domain/message_id_updater.dart';
import '../services/websocket_service.dart';
import '../widgets/message_bubble.dart';

// 聊天窗口
class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();

  // ✅ WebSocketService 实例获取器
  WebSocketService get _wsService => Get.find<WebSocketService>();

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _setupMessageStatusListener();
    _markConversationMessagesAsRead();
  }

  /// 标记当前会话的所有未读消息为已读
  void _markConversationMessagesAsRead() {
    info("👁️ 进入聊天界面，标记消息为已读...");
    final currentUserId = AppData.to.user.value.id;

    // 遍历当前会话的所有消息，找到未读的消息并发送已读ACK
    for (var message in messages) {
      // 只处理接收到的未读消息（不是自己发的）
      if (message.toUserId == currentUserId &&
          message.fromUserId != currentUserId &&
          message.status == MessageStatus.unRead) {
        info("👁️ 发送已读确认 - clientMsgId: ${message.clientMsgId}, msgId: ${message.msgId}");
        _wsService.sendReadAck(
          message.clientMsgId,
          message.msgId,
          message.fromUserId,
          message.toUserId,
        );
      }
    }
  }

  void _connectWebSocket() async {
    // 从AppData获取真实的用户信息
    final appData = AppData.to;
    if (!appData.isLoggedIn || appData.user.value.id.isEmpty) {
      info('❌ 用户未登录，无法连接WebSocket');
      return;
    }

    info("🔗 开始连接WebSocket...");
    await _wsService.initWebSocket();
    info('✅ WebSocket连接已初始化');
  }

  void _setupMessageStatusListener() {
    // 监听消息状态变化
    AppEvent.onMessageStatusChanged.stream.listen((MessageStatusChangedModel statusModel) {
      info("📊 消息状态更新: msgId=${statusModel.messageId}, status=${statusModel.messageStatus.desc}");

      if (mounted) {
        setState(() {
          // 使用双ID匹配方法查找消息
          int index = MessageIdUpdater.findMessageIndex(messages, statusModel.messageId);

          if (index != -1) {
            // 更新消息状态
            ChatMessage updatedMessage = messages[index].copyWith(
              status: statusModel.messageStatus,
            );

            // ✅ 如果携带了 serverMsgId，说明这是 SERVER_ACK，需要更新 msgId
            if (statusModel.serverMsgId != null && statusModel.serverMsgId!.isNotEmpty) {
              info("✅ 收到 SERVER_ACK，更新 msgId: ${statusModel.serverMsgId}");
              updatedMessage = updatedMessage.copyWith(msgId: statusModel.serverMsgId);
            }

            messages[index] = updatedMessage;
          } else {
            waring("⚠️ 未找到消息: ${statusModel.messageId}");
          }
        });
      } else {
        info("⚠️ Widget已销毁，跳过setState调用");
      }
    });

    // 监听接收到的消息
    AppEvent.onMessageReceived.stream.listen((ChatMessage message) {
      info("📨 收到新消息: ${message.content}");

      if (mounted) {
        setState(() {
          messages.add(message);
        });
        // 滚动到底部显示新消息
        _scrollToBottom();

        // ✅ 如果是接收到的消息（不是自己发的），自动发送已读ACK
        final currentUserId = AppData.to.user.value.id;
        if (message.toUserId == currentUserId && message.fromUserId != currentUserId) {
          info("👁️ 聊天界面打开，自动发送已读确认");
          _wsService.sendReadAck(
            message.clientMsgId,
            message.msgId,
            message.fromUserId,
            message.toUserId,
          );
        }
      } else {
        info("⚠️ Widget已销毁，跳过接收消息处理");
      }
    });
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    info("📤 准备发送消息: $content");

    // 获取当前用户ID
    final appData = AppData.to;
    final currentUserId = appData.user.value.id;

    // 获取目标用户ID（优先使用targetUserId，如果没有则使用userId）
    String targetUserId = widget.conversation.targetUserId ?? widget.conversation.userId;

    info("🔍 发送消息调试信息:");
    info("  📱 当前用户ID: $currentUserId");
    info("  🎯 目标用户ID: $targetUserId");
    info("  💬 会话userId: ${widget.conversation.userId}");
    info("  👤 会话targetUserId: ${widget.conversation.targetUserId}");

    // 创建消息（双轨制：clientMsgId待生成，msgId待服务端分配）
    ChatMessage message = ChatMessage(
      clientMsgId: '', // 空值，待WebSocketService生成
      msgId: '', // 空值，实际会被WebSocketService替换
      content: content,
      fromUserId: currentUserId,
      toUserId: targetUserId,
      type: MessageType.text.code,
      status: MessageStatus.sending, // 使用sending作为发送中状态
      timestamp: DateTime.now(),
      chatId: '', // chatId需要添加
    );

    if (mounted) {
      setState(() {
        messages.add(message);
      });
    }

    // 发送到服务器
    ChatMessage? sentMessage = await _wsService.sendMessage(message);

    if (sentMessage == null) {
      info("❌ 发送消息失败，更新消息状态为失败");
      // 更新消息状态为失败
      if (mounted) {
        setState(() {
          int index = messages.lastIndexOf(message);
          if (index != -1) {
            messages[index] = messages[index].copyWith(status: MessageStatus.fail);
          }
        });
      }
    } else {
      info("✅ 消息发送成功，等待服务器确认");
    }

    // 滚动到底部
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: AssetImage(widget.conversation.headImage), radius: 16),
            const SizedBox(width: 8),
            Text(widget.conversation.name),
          ],
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 显示更多选项
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final appData = AppData.to;
                final currentUserId = appData.user.value.id;
                return MessageBubble(
                  message: messages[index],
                  isMe: messages[index].fromUserId == currentUserId,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    // 显示更多选项
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _sendMessage(value);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}
