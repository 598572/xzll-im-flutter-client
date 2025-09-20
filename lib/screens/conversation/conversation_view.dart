import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/screens/conversation/conversation_logic.dart';

class ConversationView extends GetView<ConversationLogic> {
  const ConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("消息"), centerTitle: true),
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
