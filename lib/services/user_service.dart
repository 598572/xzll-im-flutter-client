import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import '../constants/api_constants.dart';

/// 用户相关服务
class UserService {
  
  /// 上传头像到服务器（安全版本，服务器从Token自动获取用户ID）
  static Future<String?> uploadAvatar(File file) async {
    try {
      // ✅ 获取统一认证信息
      final AppData appData = Get.find<AppData>();
      final String currentUserId = appData.user.value.id;
      final String token = appData.token.value;
      
      info('📤 开始上传头像...');
      info('📋 文件路径: ${file.path}');
      info('📋 文件大小: ${await file.length()} bytes');
      info('📋 当前用户ID: $currentUserId');
      info('📋 Token长度: ${token.length}');
      
      // ✅ 检查必要参数
      if (!await file.exists()) {
        error('❌ 文件不存在: ${file.path}');
        return null;
      }
      
      if (currentUserId.isEmpty) {
        error('❌ 用户ID为空');
        return null;
      }
      
      if (token.isEmpty) {
        error('❌ 认证token为空');
        return null;
      }
      
      final uri = Uri.parse(ApiConstants.uploadAvatar);
      info('📤 上传URL: $uri');
      
      final request = http.MultipartRequest('POST', uri);
      
      // ✅ 只添加认证头，不要添加Content-Type（让系统自动设置为multipart/form-data）
      request.headers['Authorization'] = 'Bearer ${token}';
      info('📋 请求头: ${request.headers}');
      
      // 添加文件（确保正确的Content-Type）
      final filename = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await file.readAsBytes();
      
      // 手动设置Content-Type为image/jpeg（确保后端能正确识别）
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);
      info('📎 文件字段名: file, 文件名: $filename, ContentType: image/jpeg');
      
      // 不再需要添加userId字段，服务器从Token自动获取
      info('📋 表单字段: 仅包含文件，用户ID从Token获取');
      
      info('📤 发送请求...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      info('📥 响应状态码: ${response.statusCode}');
      info('📥 响应头: ${response.headers}');
      info('📥 响应内容: $responseBody');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(responseBody);
          info('📥 解析响应JSON: $data');
          
          // ✅ 头像上传API响应格式 {"code": 1, "msg": "头像上传成功", "data": {"url": "..."}}
          if (data['code'] == 1 && data['data'] != null) {
            final responseData = data['data'] as Map<String, dynamic>;
            final String? avatarUrl = responseData['url'];
            
            if (avatarUrl != null && avatarUrl.isNotEmpty) {
              info('✅ 头像上传成功: $avatarUrl');
              return avatarUrl;
            } else {
              error('❌ 响应数据中没有找到头像URL: $responseData');
              return null;
            }
          } else {
            error('❌ 服务器返回错误: ${data['msg'] ?? '未知错误'}');
            return null;
          }
        } catch (e) {
          error('❌ 解析响应JSON失败: $e');
          error('❌ 原始响应: $responseBody');
          return null;
        }
      } else {
        error('❌ 头像上传失败，状态码: ${response.statusCode}');
        error('❌ 响应内容: $responseBody');
        return null;
      }
    } catch (e, stackTrace) {
      error('❌ 头像上传异常: $e');
      error('❌ 堆栈跟踪: $stackTrace');
      return null;
    }
  }
  
  /// 更新用户头像URL到本地数据库
  static Future<bool> updateUserAvatar(String userId, String avatarUrl) async {
    try {
      // TODO: 更新本地数据库中的头像URL
      // 也可以调用服务端接口更新
      return true;
    } catch (e) {
      log('更新用户头像失败: $e');
      return false;
    }
  }
}
