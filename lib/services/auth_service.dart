import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/api_response.dart';
import 'package:xzll_im_flutter_client/models/domain/auth_response.dart';
import 'package:xzll_im_flutter_client/models/domain/user.dart';
import 'package:xzll_im_flutter_client/models/enum/divice_type.dart';
import 'package:xzll_im_flutter_client/models/request_model.dart';
import 'package:xzll_im_flutter_client/repository/auth_repository.dart';
import 'package:xzll_im_flutter_client/repository/impl/auth_repository_impl.dart';
import 'package:xzll_im_flutter_client/utils/auth_tools.dart';

/// 认证服务（业务聚合层）
/// 职责：
/// 1. 协调仓库请求与本地缓存
/// 2. 维护内存中的当前登录状态
/// 3. 对外提供简化的登录/刷新/登出/校验 API
class AuthService  {
  // 单例
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // 仓库（网络层）
  final AuthRepository _repo = AuthRepositoryImpl();

  // 内存态
  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  int _deviceType = DeviceType.android.code;

  // 对外只读访问
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken != null && _currentUser != null;
  int get deviceType => _deviceType;

  /// 供外部(启动页)在读取缓存后设置当前认证状态
  void setAuthState({User? user, String? accessToken, String? refreshToken, required int deviceType}) {
    _currentUser = user;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _deviceType = deviceType;
  }

  /// 用户注册（维持原返回结构）
  Future<ApiResponse<User>> register(RegisterRequest request) async {
    try {
      final resp = await _repo.register(request);
      if ((resp['code'] == 1) || resp['success'] == true) {
        // 服务器可能返回 data 中的用户信息，也可能没有
        User user;
        if (resp['data'] != null) {
          user = User.fromJson(resp['data']);
        } else {
          user = User(
            id: '',
            userName: request.userName,
            phone: request.phone,
            sex: request.sex,
          );
        }
        return ApiResponse.success(user);
      }
      return ApiResponse.error(resp['msg'] ?? resp['message'] ?? '注册失败');
    } catch (e) {
      info('注册异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 用户登录
  Future<ApiResponse<User>> login(LoginRequest request) async {
    try {
      final resp = await _repo.login(request);
      if (resp['code'] == 1) {
        final data = resp['data'];
        if (data != null) {
          _accessToken = data['token'];
          _refreshToken = data['refreshToken'];
          _deviceType = request.deviceType;

            // 解析用户（JWT）
          _currentUser = _accessToken != null ? AuthTools.parseUserFromToken(_accessToken!) : null;
          _currentUser ??= User(id: '', userName: request.username);

          await AuthTools.saveAuthState(
            user: _currentUser,
            accessToken: _accessToken,
            refreshToken: _refreshToken,
            deviceType: _deviceType,
          );
          return ApiResponse.success(_currentUser!);
        }
        return ApiResponse.error('登录响应数据为空');
      }
      return ApiResponse.error(resp['msg'] ?? '登录失败');
    } catch (e) {
      info('登录异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 验证当前 accessToken 是否有效
  Future<bool> validateToken() async {
    if (_accessToken == null) return false;
    try {
      final resp = await _repo.validateToken(_accessToken!, _deviceType);
      // 后端有可能返回 success 或 valid 字段
      return resp['success'] == true || resp['valid'] == true;
    } catch (e) {
      info('Token验证异常: $e');
      return false;
    }
  }

  /// 刷新 Token
  Future<ApiResponse<String>> refreshToken() async {
    if (_refreshToken == null) {
      return ApiResponse.error('没有刷新令牌');
    }
    try {
      final resp = await _repo.refreshToken(_refreshToken!, _deviceType);
      if (resp['code'] == 1 || resp['success'] == true) {
        // 兼容之前 AuthResponse 结构
        final authResp = AuthResponse.fromJson(_adaptRefreshJson(resp));
        if (authResp.isSuccess) {
          _accessToken = authResp.accessToken;
          if (authResp.refreshToken != null) {
            _refreshToken = authResp.refreshToken;
          }
          // 解析用户（若之前未解析）
          if (_currentUser == null && _accessToken != null) {
            _currentUser = AuthTools.parseUserFromToken(_accessToken!);
          }
          await AuthTools.saveAuthState(
            user: _currentUser,
            accessToken: _accessToken,
            refreshToken: _refreshToken,
            deviceType: _deviceType,
          );
          return ApiResponse.success(_accessToken!);
        }
        return ApiResponse.error(authResp.errorDescription ?? 'Token刷新失败');
      }
      return ApiResponse.error(resp['msg'] ?? 'Token刷新失败');
    } catch (e) {
      info('Token刷新异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 用户登出
  Future<bool> logout() async {
    try {
      if (_accessToken != null && _currentUser != null) {
        await _repo.logout(_accessToken!, _currentUser!.id, _deviceType);
      }
    } catch (e) {
      info('登出请求异常: $e');
    }
    _clearMemory();
    await AuthTools.clearAuthState();
    return true;
  }

  /// 授权头
  Map<String, String> getAuthHeaders() {
    if (_accessToken != null) {
      return {'Authorization': 'Bearer $_accessToken', 'Content-Type': 'application/json'};
    }
    return {'Content-Type': 'application/json'};
  }

  void _clearMemory() {
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
  }

  /// 适配仓库刷新结构为 AuthResponse 需要的JSON
  Map<String, dynamic> _adaptRefreshJson(Map<String, dynamic> raw) {
    // 假设后端刷新返回数据格式为 { code:1, data:{ token:..., refreshToken:... } }
    final data = raw['data'];
    return {
      'accessToken': data?['token'],
      'refreshToken': data?['refreshToken'],
      'tokenType': data?['tokenType'],
      'expiresIn': data?['expiresIn'],
      'scope': data?['scope'],
      // error 字段保持为空即可
    };
  }
}
