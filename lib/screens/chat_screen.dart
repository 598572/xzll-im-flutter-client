/*
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:xzll_im_flutter_client/constant/constant.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';
import '../models/domain/chat_message.dart';
import '../models/domain/conversation.dart';
import '../services/websocket_service.dart';
import '../services/auth_service.dart';
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
  FlutterSoundRecorder? _recorder;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _connectWebSocket();
    _setupMessageStatusListener();
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      await _recorder!.openRecorder();
    }
  }

  void _connectWebSocket() async {
    // 从认证服务获取真实的用户信息
    final authService = AuthService();
    if (!authService.isLoggedIn || authService.currentUser == null) {
      info('❌ 用户未登录，无法连接WebSocket');
      return;
    }

    info("🔗 开始连接WebSocket...");
    bool connected = await WebSocketService.instance.connect(
      authService.currentUser!.id,
      authService.accessToken ?? '',
    );
    if (connected) {
      info('✅ WebSocket连接成功');
    } else {
      info('❌ WebSocket连接失败');
    }
  }

  void _setupMessageStatusListener() {
    // 监听消息状态变化
    WebSocketService.instance.onMessageStatusChanged = (String msgId, MessageStatus status) {
      info("📊 消息状态更新: $msgId -> $status");
      // 检查Widget是否还在树中
      if (mounted) {
        setState(() {
          int index = messages.indexWhere((m) => m.msgId == msgId);
          if (index != -1) {
            messages[index] = ChatMessage(
              msgId: messages[index].msgId,
              content: messages[index].content,
              fromUserId: messages[index].fromUserId,
              toUserId: messages[index].toUserId,
              type: messages[index].type,
              status: status,
              timestamp: messages[index].timestamp,
              withdrawStatus: messages[index].withdrawStatus,
            );
          }
        });
      } else {
        info("⚠️ Widget已销毁，跳过setState调用");
      }
    };

    // 监听接收到的消息
    WebSocketService.instance.onMessageReceived = (ChatMessage message) {
      info("📨 收到新消息: ${message.content}");
      // 检查Widget是否还在树中
      if (mounted) {
        setState(() {
          messages.add(message);
        });
        // 滚动到底部显示新消息
        _scrollToBottom();
      } else {
        info("⚠️ Widget已销毁，跳过接收消息处理");
      }
    };
  }

  void _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    info("📤 准备发送消息: $content");

    // 先获取真实的消息ID（优先从缓存获取）
    String? msgId = await WebSocketService.instance.getSingleMsgId();
    if (msgId == null) {
      info("❌ 获取消息ID失败，无法发送消息");
      return;
    }

    info("🆔 获取到消息ID: $msgId");

    // 获取当前用户ID
    final authService = AuthService();
    final currentUserId = authService.currentUser?.id ?? '';

    // 获取目标用户ID（优先使用targetUserId，如果没有则使用userId）
    String targetUserId = widget.conversation.targetUserId ?? widget.conversation.userId;

    info("🔍 发送消息调试信息:");
    info("  📱 当前用户ID: $currentUserId");
    info("  🎯 目标用户ID: $targetUserId");
    info("  💬 会话userId: ${widget.conversation.userId}");
    info("  👤 会话targetUserId: ${widget.conversation.targetUserId}");

    // 创建消息（使用真实的消息ID和发送中状态）
    ChatMessage message = ChatMessage(
      msgId: msgId,
      content: content,
      fromUserId: currentUserId,
      toUserId: targetUserId,
      type: MessageType.text,
      status: MessageStatus.serverReceived, // 使用serverReceived作为发送中状态
      timestamp: DateTime.now(),
    );

    if (mounted) {
      setState(() {
        messages.add(message);
      });
    }

    // 发送到服务器
    bool success = await WebSocketService.instance.sendMessageWithId(msgId, content, targetUserId);

    if (!success) {
      info("❌ 发送消息失败，更新消息状态为失败");
      // 更新消息状态为失败
      if (mounted) {
        setState(() {
          int index = messages.indexWhere((m) => m.msgId == msgId);
          if (index != -1) {
            messages[index] = ChatMessage(
              msgId: messages[index].msgId,
              content: messages[index].content,
              fromUserId: messages[index].fromUserId,
              toUserId: messages[index].toUserId,
              type: messages[index].type,
              status: MessageStatus.fail,
              timestamp: messages[index].timestamp,
              withdrawStatus: messages[index].withdrawStatus,
            );
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
          duration: Duration(milliseconds: 300),
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
            SizedBox(width: 8),
            Text(widget.conversation.name),
          ],
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
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
                final authService = AuthService();
                final currentUserId = authService.currentUser?.id ?? '';
                return MessageBubble(
                  message: messages[index],
                  isMe: messages[index].fromUserId == currentUserId,
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  icon: Icon(Icons.send),
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
    _recorder?.closeRecorder();

    // 清理WebSocket回调，避免内存泄漏
    WebSocketService.instance.onMessageStatusChanged = null;
    WebSocketService.instance.onMessageReceived = null;

    super.dispose();
  }
}
*/
