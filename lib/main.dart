import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_theme.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/router/router_pages.dart';

import 'constant/lang/app_translations.dart';

// 应用程序入口
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const XzllImClient());
}

class XzllImClient extends StatelessWidget {
  const XzllImClient({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'app_name'.tr,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light.copyWith(primaryColor: Colors.purple),
      darkTheme: AppTheme.dark.copyWith(primaryColor: Colors.purple),
      getPages: RouterPages.pages,
      initialRoute: RouterName.splash,
      translations: AppTranslation(),
      // TODO: 本地缓存Local
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('zh', 'CN'),
    );
  }
}
