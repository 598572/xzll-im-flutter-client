import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';

class ChatLogic extends GetxController {
  /// 当前会话
  late Conversation conversation;

  @override
  void onInit() {
    super.onInit();
    // 从路由参数中获取会话对象
    conversation = Get.arguments as Conversation;
  }
}
