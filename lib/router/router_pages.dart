import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/screens/auth/login/login_binding.dart';
import 'package:xzll_im_flutter_client/screens/auth/login/login_view.dart';
import 'package:xzll_im_flutter_client/screens/auth/register/register_binding.dart';
import 'package:xzll_im_flutter_client/screens/auth/register/register_view.dart';
import 'package:xzll_im_flutter_client/screens/chat/chat_binding.dart';
import 'package:xzll_im_flutter_client/screens/chat/chat_view.dart';
import 'package:xzll_im_flutter_client/screens/home/home_binding.dart';
import 'package:xzll_im_flutter_client/screens/home/home_page.dart';
import 'package:xzll_im_flutter_client/screens/splash/splash_binding.dart';
import 'package:xzll_im_flutter_client/screens/splash/splash_page.dart';

sealed class RouterPages {
  static List<GetPage> pages = [
    GetPage(name: RouterName.splash, page: () => const SplashPage(), binding: SplashBinding()),
    GetPage(name: RouterName.login, page: () => const LoginView(), binding: LoginBinding()),
    GetPage(
      name: RouterName.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(name: RouterName.home, page: () => HomePage(), binding: HomeBinding()),
    GetPage(name: RouterName.chat, page: () => ChatView(), binding: ChatBinding()),
  ];
}
