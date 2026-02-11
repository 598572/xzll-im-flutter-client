import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/app_theme.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/router/router_pages.dart';
import 'package:xzll_im_flutter_client/services/imsdk_manager.dart';

import 'constant/custom_log.dart';
import 'models/enum/web_socket_status.dart';

// 应用程序入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 初始化服务
  await initServices();

  runApp(const XzllImClient());
}

/// 初始化服务
Future<void> initServices() async {
  info('🔧 初始化服务...');

  // 注册AppData
  Get.put(AppData());
  info('✅ AppData 已注册');

  // 注册IMSDKManager
  final imSdkManager = Get.put(IMSDKManager());
  await imSdkManager.init();
  info('✅ IMSDKManager 已注册');

  info('🎉 所有服务初始化完成');
}

class XzllImClient extends StatefulWidget {
  const XzllImClient({super.key});

  @override
  State<XzllImClient> createState() => _XzllImClientState();
}

class _XzllImClientState extends State<XzllImClient> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    info("✅ XzllImClient 已初始化，开始监听应用生命周期");
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
    // 应用回到前台，检查SDK连接状态
    info("🔄 应用回到前台，检查连接状态");

    try {
      // ✅ 通知SDK应用回到前台
      if (Get.isRegistered<IMSDKManager>()) {
        Get.find<IMSDKManager>().setAppInBackground(false);
      }

      // 检查WebSocket连接状态
      final wsStatus = AppEvent.webSocketStatus.value;
      info("   当前WebSocket状态: ${wsStatus.name}");

      // 如果连接断开，尝试重连
      if (wsStatus != WebSocketStatus.connected) {
        info("   ⚠️ WebSocket未连接，尝试重连");
        if (Get.isRegistered<IMSDKManager>() && IMSDKManager.to.isInitialized) {
          IMSDKManager.to.connect();
        }
      } else {
        info("   ✅ WebSocket已连接");
      }
    } catch (e) {
      error("❌ 检查WebSocket状态失败: $e");
    }
  }

  /// 应用进入后台时的处理
  void _onAppPaused() {
    // 应用进入后台，保持SDK连接以接收消息推送
    info("💡 应用进入后台，保持SDK连接以接收消息推送");

    try {
      if (Get.isRegistered<IMSDKManager>()) {
        Get.find<IMSDKManager>().setAppInBackground(true);
      }
    } catch (e) {
      error("❌ 通知SDK服务失败: $e");
    }

    // 打印当前WebSocket状态
    final wsStatus = AppEvent.webSocketStatus.value;
    info("   当前WebSocket状态: ${wsStatus.name}");
    info("   ✅ 连接将保持活跃");
  }

  /// 应用即将终止时的处理
  void _onAppDetached() {
    // 应用即将被系统终止，此时可以清理资源
    info("🧹 应用即将终止，清理资源");
    // 这里可以添加清理逻辑，但通常不需要手动断开WebSocket
    // 因为进程终止时会自动断开所有连接
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'OkIM',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light.copyWith(primaryColor: Colors.purple),
      darkTheme: AppTheme.dark.copyWith(primaryColor: Colors.purple),
      getPages: RouterPages.pages,
      initialRoute: RouterName.splash,
    );
  }
}
