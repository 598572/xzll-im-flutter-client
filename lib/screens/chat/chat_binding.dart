import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/screens/chat/chat_logic.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatLogic());
  }
}
