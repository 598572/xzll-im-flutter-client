import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/constant.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/services/imsdk_manager.dart';

class HomeLogic extends GetxService {
  final AppData appData = Get.find<AppData>();
  final IMSDKManager imSdkManager = Get.find<IMSDKManager>();

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
      info('✅ WebSocket已连接，会话列表会自动更新');
    }
  }

  void changePage(int index) {
    // ✅ 禁用重复点击，避免不必要的状态更新
    if (index != currentIndex.value) {
      currentIndex.value = index;
      // ✅ 不再需要pageController，IndexedStack会自动切换
    }
  }

  Future<void> init() async {
    // ✅ SDK自动处理数据库初始化，无需手动操作
    // WebSocket已在SDK中自动管理，无需手动初始化
    if (!imSdkManager.isInitialized) {
      await imSdkManager.init();
    }
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
    super.onClose();
  }
}
