import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/screens/splash/splash_logic.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashLogic());
  }
}
