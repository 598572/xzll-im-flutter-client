import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';
import 'package:xzll_im_flutter_client/services/websocket_service.dart';

/// 应用生命周期管理服务
/// 负责监听应用生命周期状态变化，确保WebSocket在适当的时候保持连接
class AppLifecycleService extends GetxService with WidgetsBindingObserver {
  
  @override
  void onInit() {
    super.onInit();
    // 注册应用生命周期观察者
    WidgetsBinding.instance.addObserver(this);
    info("✅ AppLifecycleService 已初始化，开始监听应用生命周期");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    info("📱 应用生命周期状态变化: ${state.name}");
    
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用回到前台
        info("✅ 应用已回到前台");
        _onAppResumed();
        break;
        
      case AppLifecycleState.inactive:
        // 应用处于不活动状态（如来电、系统弹窗等）
        info("⚠️ 应用处于不活动状态");
        // 不做任何操作，保持连接
        break;
        
      case AppLifecycleState.paused:
        // 应用进入后台（按Home键）
        info("⏸️ 应用已进入后台");
        _onAppPaused();
        break;
        
      case AppLifecycleState.detached:
        // 应用即将被系统终止
        info("🛑 应用即将终止");
        _onAppDetached();
        break;
        
      case AppLifecycleState.hidden:
        // 应用被隐藏（较新的Flutter版本）
        info("👻 应用已被隐藏");
        // 不做任何操作，保持连接
        break;
    }
  }

  /// 应用回到前台时的处理
  void _onAppResumed() {
    // 应用回到前台，可以在这里检查WebSocket连接状态
    // 如果连接断开，可以尝试重连
    info("🔄 应用回到前台，检查连接状态");
    
    try {
      // ✅ 通知WebSocket服务应用回到前台，恢复心跳检查
      if (Get.isRegistered<WebSocketService>()) {
        Get.find<WebSocketService>().setAppInBackground(false);
      }
      
      // 检查WebSocket连接状态
      final wsStatus = AppEvent.webSocketStatus.value;
      info("   当前WebSocket状态: ${wsStatus.name}");
      
      // 如果连接断开，尝试重连
      if (wsStatus != WebSocketStatus.connected) {
        info("   ⚠️ WebSocket未连接，尝试初始化连接");
        if (Get.isRegistered<WebSocketService>()) {
          Get.find<WebSocketService>().initWebSocket();
        }
      } else {
        info("   ✅ WebSocket已连接，心跳已恢复");
      }
    } catch (e) {
      error("❌ 检查WebSocket状态失败: $e");
    }
  }

  /// 应用进入后台时的处理
  void _onAppPaused() {
    // ✅ 关键：应用进入后台时，不断开WebSocket连接
    // 因为：
    // 1. 进程还在运行，只是不在前台
    // 2. 需要接收消息推送
    // 3. 保持在线状态
    info("💡 应用进入后台，保持WebSocket连接以接收消息推送");
    
    // ✅ 暂停心跳检查（因为后台Timer会被挂起），但保持连接
    try {
      if (Get.isRegistered<WebSocketService>()) {
        Get.find<WebSocketService>().setAppInBackground(true);
      }
    } catch (e) {
      error("❌ 通知WebSocket服务失败: $e");
    }
    
    // 打印当前WebSocket状态以供调试
    final wsStatus = AppEvent.webSocketStatus.value;
    info("   当前WebSocket状态: ${wsStatus.name}");
    info("   ✅ 连接将保持活跃（心跳已暂停）");
  }

  /// 应用即将终止时的处理
  void _onAppDetached() {
    // 应用即将被系统终止，此时可以清理资源
    info("🧹 应用即将终止，清理资源");
    // 这里可以添加清理逻辑，但通常不需要手动断开WebSocket
    // 因为进程终止时会自动断开所有连接
  }

  @override
  void onClose() {
    // 移除应用生命周期观察者
    WidgetsBinding.instance.removeObserver(this);
    info("👋 AppLifecycleService 已关闭");
    super.onClose();
  }
}
