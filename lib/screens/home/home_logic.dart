import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/constant.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/services/data_base_service.dart';
import 'package:xzll_im_flutter_client/services/websocket_service.dart';

class HomeLogic extends GetxService {
  final AppData appData = Get.find<AppData>();
  final WebSocketService webSocketService = Get.find<WebSocketService>();
  final DataBaseService dataBaseService = Get.find<DataBaseService>();

  final PageController pageController = PageController();

  final RxInt currentIndex = 0.obs;
  
  /// 事件流订阅
  StreamSubscription? _friendRequestSubscription;

  @override
  void onInit() {
    super.onInit();
    AppEvent.webSocketStatus.listen(_webSocketStatusChanged);
    _setupFriendRequestListener();
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

  /// 设置好友申请推送监听
  void _setupFriendRequestListener() {
    _friendRequestSubscription = AppEvent.onFriendRequestPush.stream.listen((FriendRequestPushMessage pushMessage) {
      info("🔔 收到好友申请推送: ${pushMessage.pushContent}");
      _handleFriendRequestPush(pushMessage);
    });
  }

  /// 处理好友申请推送
  void _handleFriendRequestPush(FriendRequestPushMessage pushMessage) {
    // 显示推送通知
    Get.snackbar(
      pushMessage.pushTitle ?? '好友通知',
      pushMessage.pushContent ?? '',
      icon: Icon(
        pushMessage.isNewRequest ? Icons.person_add : Icons.notifications,
        color: Colors.white,
      ),
      backgroundColor: pushMessage.isNewRequest ? Colors.purple : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () {
          // 跳转到通讯录页面
          currentIndex.value = 1; // 切换到通讯录页面
          pageController.jumpToPage(1);
          
          // 延迟一下再跳转到好友申请页面
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.toNamed(RouterName.friendRequest);
          });
        },
        child: const Text('查看', style: TextStyle(color: Colors.white)),
      ),
    );
    
    info("✅ 好友申请推送处理完成");
  }

  @override
  void onClose() {
    // 清理订阅
    _friendRequestSubscription?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
