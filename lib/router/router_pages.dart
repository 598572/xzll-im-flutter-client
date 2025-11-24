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
import 'package:xzll_im_flutter_client/screens/user_search_screen.dart';
import 'package:xzll_im_flutter_client/screens/friend_request_screen.dart';
import '../pages/profile_page_getx.dart';
import '../pages/settings_page.dart';
import '../controllers/profile_controller.dart';

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
    GetPage(name: RouterName.userSearch, page: () => const UserSearchScreen()),
    GetPage(name: RouterName.friendRequest, page: () => const FriendRequestScreen()),
    GetPage(
      name: RouterName.profile,
      page: () => ProfilePage(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileController());
      }),
    ),
    GetPage(
      name: RouterName.settings,
      page: () => SettingsPage(),
    ),
  ];
}
