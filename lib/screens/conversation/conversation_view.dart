import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/screens/conversation/conversation_logic.dart';
import 'package:xzll_im_flutter_client/screens/widgets/web_socket_status_widget.dart';

class ConversationView extends GetView<ConversationLogic> {
  const ConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [Text("消息"), WebSocketStatusWidget()]),
        centerTitle: true,
        actions: [
          PullDownButton(
            routeTheme: PullDownMenuRouteTheme(width: 150),
            itemBuilder: (BuildContext context) {
              return [
                PullDownMenuItem(
                  onTap: controller.goToAddFriend,
                  title: "添加好友",
                  icon: Icons.person_add_alt,
                ),
                PullDownMenuItem(
                  onTap: controller.createGroupChat,
                  title: "创建群聊",
                  icon: Icons.group_add_outlined,
                ),
                PullDownMenuItem(
                  onTap: controller.scanQRCode,
                  title: "扫一扫",
                  icon: Icons.qr_code_scanner_outlined,
                ),
              ];
            },
            buttonBuilder: (BuildContext context, Future<void> Function() showMenu) {
              return IconButton(onPressed: showMenu, icon: Icon(Icons.add_circle_outline));
            },
          ),
        ],
      ),
      body: Obx(() {
        // 加载中状态
        if (controller.isLoading.value && controller.conversationList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
                SizedBox(height: 16),
                Text('加载会话列表中...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // 错误状态
        if (controller.errorMessage.value.isNotEmpty && controller.conversationList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadConversations,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text('重试', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        // 空列表状态
        if (controller.conversationList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无会话', style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 8),
                Text('点击右上角加号添加好友开始聊天吧', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          );
        }

        // 会话列表
        return RefreshIndicator(
          onRefresh: controller.refreshConversations,
          child: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              Conversation conversation = controller.conversationList[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: const Icon(Icons.person, color: Colors.purple),
                ),
                title: Text(
                  conversation.targetUserName ?? "未知用户",
                  style: Get.textTheme.titleSmall,
                ),
                subtitle: Text(
                  conversation.lastMessage ?? "",
                  style: Get.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      conversation.timestamp,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (conversation.unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 20),
                        child: Text(
                          conversation.unreadCount > 99 ? '99+' : '${conversation.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () => controller.openChat(conversation),
              );
            },
            itemCount: controller.conversationList.length,
          ),
        );
      }),
    );
  }
}
