import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/models/domain/user.dart';

class AppData extends GetxService {
  ///当前登录的用户的数据
  final Rx<User> user = Rx<User>(User(id: "", userName: ''));

  ///Token
  final RxString token = ''.obs;

  ///RefreshToken
  final RxString refreshToken = ''.obs;
}
