import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_theme.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/router/router_pages.dart';
import 'package:xzll_im_flutter_client/services/app_lifecycle_service.dart';

// 应用程序入口
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // ✅ 初始化应用生命周期管理服务（永久服务）
  Get.put(AppLifecycleService(), permanent: true);
  
  runApp(const XzllImClient());
}

class XzllImClient extends StatelessWidget {
  const XzllImClient({super.key});

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
