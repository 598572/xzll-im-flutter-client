import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xzll_im_flutter_client/constant/cache_keys.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/user.dart';
import 'package:xzll_im_flutter_client/models/enum/divice_type.dart';

sealed class AuthTools {
  /// 读取缓存的认证信息
  static Future<({User? user, String? accessToken, String? refreshToken, int deviceType})> loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final access = prefs.getString(CacheKeys.accessTokenKey);
      final refresh = prefs.getString(CacheKeys.refreshTokenKey);
      final device = prefs.getInt(CacheKeys.deviceTypeKey) ?? DeviceType.android.code;
      User? user;
      final userStr = prefs.getString(CacheKeys.userInfoKey);
      if (userStr != null) {
        final json = jsonDecode(userStr);
        user = User.fromJson(json);
      }
      return (user: user, accessToken: access, refreshToken: refresh, deviceType: device);
    } catch (e) {
      info('读取认证缓存失败: $e');
      return (user: null, accessToken: null, refreshToken: null, deviceType: DeviceType.android.code);
    }
  }

  /// 保存认证信息
  static Future<void> saveAuthState({required User? user, required String? accessToken, required String? refreshToken, required int deviceType}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (accessToken != null) {
        await prefs.setString(CacheKeys.accessTokenKey, accessToken);
      }
      if (refreshToken != null) {
        await prefs.setString(CacheKeys.refreshTokenKey, refreshToken);
      }
      if (user != null) {
        await prefs.setString(CacheKeys.userInfoKey, jsonEncode(user.toJson()));
      }
      await prefs.setInt(CacheKeys.deviceTypeKey, deviceType);
    } catch (e) {
      info('保存认证缓存失败: $e');
    }
  }

  /// 清除认证缓存
  static Future<void> clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(CacheKeys.accessTokenKey);
      await prefs.remove(CacheKeys.refreshTokenKey);
      await prefs.remove(CacheKeys.userInfoKey);
      await prefs.remove(CacheKeys.deviceTypeKey);
    } catch (e) {
      info('清除认证缓存失败: $e');
    }
  }

  /// 从JWT中解析用户
  static User? parseUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      info('JWT Payload: $json');
      return User(
        id: json['id']?.toString() ?? '',
        userName: json['user_name'] ?? '',
      );
    } catch (e) {
      info('解析JWT失败: $e');
      return null;
    }
  }
}

