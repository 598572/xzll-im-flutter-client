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
                PullDownMenuItem(onTap: () {}, title: "添加好友", icon: Icons.person_add_alt),
                PullDownMenuItem(onTap: () {}, title: "创建群聊", icon: Icons.group_add_outlined),
                PullDownMenuItem(onTap: () {}, title: "扫一扫", icon: Icons.qr_code_scanner_outlined),
              ];
            },
            buttonBuilder: (BuildContext context, Future<void> Function() showMenu) {
              return IconButton(onPressed: showMenu, icon: Icon(Icons.add_circle_outline));
            },
          ),
        ],
      ),
      body: Obx(() {
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            Conversation conversation = controller.conversationList[index];
            return ListTile(
              leading: FlutterLogo(size: 36),
              title: Text(conversation.targetUserName ?? "未知用户", style: Get.textTheme.titleSmall),
              subtitle: Text(conversation.lastMessage ?? "", style: Get.textTheme.bodySmall),
            );
          },
          itemCount: controller.conversationList.length,
        );
      }),
    );
  }
}
