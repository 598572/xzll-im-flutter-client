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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text("conversation".tr), WebSocketStatusWidget()],
        ),
        centerTitle: true,
        actions: [
          PullDownButton(
            routeTheme: PullDownMenuRouteTheme(width: 150),
            itemBuilder: (BuildContext context) {
              return [
                PullDownMenuItem(onTap: () {}, title: "add_friend".tr, icon: Icons.person_add_alt),
                PullDownMenuItem(
                  onTap: () {},
                  title: "create_group_chat".tr,
                  icon: Icons.group_add_outlined,
                ),
                PullDownMenuItem(
                  onTap: () {},
                  title: "scan_it".tr,
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
        return ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            Conversation conversation = controller.conversationList[index];
            return ListTile(
              leading: FlutterLogo(size: 36),
              title: Text(
                conversation.targetUserName ?? "unknown_user".tr,
                style: Get.textTheme.titleSmall,
              ),
              subtitle: Text(conversation.lastMessage ?? "", style: Get.textTheme.bodySmall),
            );
          },
          itemCount: controller.conversationList.length,
        );
      }),
    );
  }
}
