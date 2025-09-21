import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/services/websocket_service.dart';

class ConversationLogic extends GetxController {
  final WebSocketService webSocketService = Get.find<WebSocketService>();

  ///会话列表
  final RxList<Conversation> conversationList = <Conversation>[].obs;

  @override
  void onInit() {
    super.onInit();
    AppEvent.onConversationsUpdated.listen(onConversationsUpdate);
    AppEvent.onConversationUpdated.listen(onConversationUpdate);
  }

  void onConversationsUpdate(List<Conversation> data) {
    conversationList.assignAll(data);
  }

  void onConversationUpdate(Conversation data) {
    int index = conversationList.indexWhere(
      (element) => element.userId == data.userId && element.targetUserId == data.targetUserId,
    );
    if (index != -1) {
      conversationList[index] = data;
      conversationList.refresh();
    } else {
      conversationList.add(data);
    }
  }
}
