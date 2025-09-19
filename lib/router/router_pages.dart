import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/screens/home_screen.dart';
import 'package:xzll_im_flutter_client/screens/login_screen.dart';
import 'package:xzll_im_flutter_client/screens/register_screen.dart';
import 'package:xzll_im_flutter_client/screens/splash/splash_binding.dart';
import 'package:xzll_im_flutter_client/screens/splash/splash_page.dart';

sealed class RouterPages {
  static List<GetPage> pages = [
    GetPage(name: RouterName.splash, page: () => const SplashPage(), binding: SplashBinding()),
    GetPage(name: RouterName.login, page: () => LoginScreen()),
    GetPage(name: RouterName.register, page: () => RegisterScreen()),
    GetPage(name: RouterName.home, page: () => HomeScreen()),
  ];
}
