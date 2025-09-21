import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/models/domain/user.dart';
import 'package:xzll_im_flutter_client/utils/auth_tools.dart';

class AppData extends GetxService {
  static AppData get to => Get.find();

  ///当前登录的用户的数据
  final Rx<User> user = Rx<User>(User(id: "", userName: ''));
  String get currentUserId => user.value.id;

  ///Token
  final RxString token = ''.obs;

  ///RefreshToken
  final RxString refreshToken = ''.obs;

  ///设备类型
  final RxInt deviceType = 1.obs;

  // 计算属性
  bool get isLoggedIn => token.value.isNotEmpty && user.value.id.isNotEmpty;

  /// 设置认证状态
  void setAuthState({User? user, String? accessToken, String? refreshToken, int? deviceType}) {
    if (user != null) this.user.value = user;
    if (accessToken != null) token.value = accessToken;
    if (refreshToken != null) this.refreshToken.value = refreshToken;
    if (deviceType != null) this.deviceType.value = deviceType;
  }

  /// 清除认证状态
  void clearAuthState() {
    user.value = User(id: "", userName: '');
    token.value = '';
    refreshToken.value = '';
    deviceType.value = 1;
  }

  /// 更新用户信息
  void updateUser(User user) {
    this.user.value = user;
  }

  /// 更新Token
  void updateTokens({String? accessToken, String? refreshToken}) {
    if (accessToken != null) token.value = accessToken;
    if (refreshToken != null) this.refreshToken.value = refreshToken;
  }

  /// 授权头
  Map<String, String> getAuthHeaders() {
    if (token.value.isNotEmpty) {
      return {'Authorization': 'Bearer ${token.value}', 'Content-Type': 'application/json'};
    }
    return {'Content-Type': 'application/json'};
  }

  /// 保存认证状态到本地
  Future<void> saveAuthState() async {
    await AuthTools.saveAuthState(
      user: user.value.id.isEmpty ? null : user.value,
      accessToken: token.value.isEmpty ? null : token.value,
      refreshToken: refreshToken.value.isEmpty ? null : refreshToken.value,
      deviceType: deviceType.value,
    );
  }

  /// 清理本地认证状态
  Future<void> clearLocalAuthState() async {
    clearAuthState();
    await AuthTools.clearAuthState();
  }
}
