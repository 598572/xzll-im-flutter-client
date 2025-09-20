import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/screens/contacts/contacts_logic.dart';
import 'package:xzll_im_flutter_client/screens/conversation/conversation_logic.dart';
import 'package:xzll_im_flutter_client/screens/discover/discover_logic.dart';
import 'package:xzll_im_flutter_client/screens/home/home_logic.dart';
import 'package:xzll_im_flutter_client/screens/mine/mine_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomeLogic());
    Get.lazyPut(() => ConversationLogic());
    Get.lazyPut(() => ContactsLogic());
    Get.lazyPut(() => DiscoverLogic());
    Get.lazyPut(() => MineLogic());
  }
}
