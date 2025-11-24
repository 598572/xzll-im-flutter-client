import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/api_constants.dart';
import '../constants/device_type.dart';
import '../constant/app_data.dart';
import '../constant/custom_log.dart';

/// 认证服务
class AuthService {
  /// 用户登出
  static Future<bool> logout() async {
    try {
      // ✅ 获取AppData服务
      final AppData appData = Get.find<AppData>();
      final String userId = appData.user.value.id;
      
      if (userId.isEmpty) {
        error('❌ 用户ID为空，无法执行登出');
        return false;
      }
      
      // ✅ 获取当前设备类型
      final currentDevice = DeviceType.currentDeviceType;
      info('📱 当前设备类型: ${currentDevice.description} (代码: ${currentDevice.code})');
      
      // ✅ 构建请求数据
      final logoutData = {
        'userId': userId,
        'deviceType': currentDevice.code,
      };
      
      info('📤 开始执行登出请求...');
      info('📋 请求数据: $logoutData');
      
      // ✅ 调用登出API
      final response = await http.post(
        Uri.parse(ApiConstants.logout),
        headers: {
          ...appData.getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode(logoutData),
      );
      
      info('📥 登出响应状态码: ${response.statusCode}');
      info('📥 登出响应内容: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          
          // ✅ 检查服务器响应格式 {"code": 1, "msg": "登出成功，共登出1个token", "data": null}
          if (responseData is Map<String, dynamic> && responseData['code'] == 1) {
            info('✅ 服务器登出成功: ${responseData['msg']}');
            return true;
          } else {
            error('❌ 服务器登出失败: ${responseData['msg'] ?? '未知错误'}');
            return false;
          }
        } catch (e) {
          error('❌ 解析登出响应失败: $e');
          error('❌ 原始响应: ${response.body}');
          return false;
        }
      } else {
        error('❌ 登出请求失败，状态码: ${response.statusCode}');
        error('❌ 响应内容: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      error('❌ 登出异常: $e');
      error('❌ 堆栈跟踪: $stackTrace');
      return false;
    }
  }
}
