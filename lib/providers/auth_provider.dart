import 'package:flutter/foundation.dart';

/// 认证状态管理
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get token => _token;

  /// 登录
  Future<bool> login(String userId, String password) async {
    try {
      // TODO: 实际的登录逻辑
      // 这里先模拟登录成功
      _isLoggedIn = true;
      _userId = userId;
      _token = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 退出登录
  void logout() {
    _isLoggedIn = false;
    _userId = null;
    _token = null;
    notifyListeners();
  }

  /// 检查登录状态
  Future<void> checkAuthStatus() async {
    // TODO: 从本地存储检查登录状态
    // 这里先设为未登录状态
    _isLoggedIn = false;
    notifyListeners();
  }
}
