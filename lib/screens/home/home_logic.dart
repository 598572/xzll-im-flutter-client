import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/constant.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';
import 'package:xzll_im_flutter_client/services/data_base_service.dart';
import 'package:xzll_im_flutter_client/services/websocket_service.dart';

class HomeLogic extends GetxService {
  final AppData appData = Get.find<AppData>();
  final WebSocketService webSocketService = Get.find<WebSocketService>();
  final DataBaseService dataBaseService = Get.find<DataBaseService>();

  final PageController pageController = PageController();

  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    AppEvent.webSocketStatus.listen(_webSocketStatusChanged);
  }

  @override
  void onReady() async {
    super.onReady();
    await init();
  }

  void _webSocketStatusChanged(WebSocketStatus status) async {
    info("WebSocketStatus: ${status.name}");
    if (status == WebSocketStatus.connected) {
      await webSocketService.getMsgIdsFromServer();
      webSocketService.requestConversations();
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  Future<void> init() async {
    await dataBaseService.initDatabase(userId: appData.currentUserId);
    // 初始化服务
    await webSocketService.initWebSocket();
  }
}
