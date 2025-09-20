import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';

class ConversationLogic extends GetxController {
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
