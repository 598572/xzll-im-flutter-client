import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/screens/chat/chat_logic.dart';
import 'package:xzll_im_flutter_client/widgets/message_bubble.dart';

class ChatView extends GetView<ChatLogic> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              backgroundImage: controller.conversation.headImage.startsWith('http')
                  ? NetworkImage(controller.conversation.headImage)
                  : AssetImage(controller.conversation.headImage) as ImageProvider,
            ),
            const SizedBox(width: 8),
            Text(controller.conversation.name),
          ],
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Get.snackbar('提示', '更多功能开发中...');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.purple.withValues(alpha: 0.1),
                        backgroundImage: controller.conversation.headImage.startsWith('http')
                            ? NetworkImage(controller.conversation.headImage)
                            : AssetImage(controller.conversation.headImage) as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.conversation.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '开始聊天吧',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMe = message.fromUserId == controller.appData.user.value.id;
                  
                  return MessageBubble(
                    message: message,
                    isMe: isMe,
                    onRetry: () => controller.retryMessage(message),
                  );
                },
              );
            }),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Get.snackbar('提示', '附加功能开发中...');
            },
          ),
          Expanded(
            child: TextField(
              controller: controller.textController,
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
                _sendMessage();
              },
            ),
          ),
          Obx(() => IconButton(
            icon: controller.isSending.value 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: controller.isSending.value ? null : _sendMessage,
          )),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = controller.textController.text.trim();
    if (text.isNotEmpty) {
      controller.sendTextMessage(text);
      controller.textController.clear();
    }
  }
}
