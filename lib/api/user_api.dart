import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/user_info.dart';
import '../config/api_config.dart';

/// 用户相关API
class UserApi {
  
  /// 获取我的个人信息
  static Future<UserInfo?> getMyUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/profile/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.token}',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // 适配API响应格式: { "code": 1, "msg": "响应成功", "data": {...} }
        if (responseData != null && responseData['code'] == 1 && responseData['data'] != null) {
          final data = responseData['data'];
          log('Fetched my user info from /me endpoint: ${data['userName']}');
          
          // 转换为UserInfo格式
          return UserInfo(
            userId: data['userId']?.toString() ?? '',
            userName: data['userName']?.toString() ?? '',
            userFullName: data['userFullName']?.toString(),
            headImage: data['headImage']?.toString(),
            sex: data['sex'] != null ? int.tryParse(data['sex'].toString()) : null,
          );
        }
        return null;
      } else {
        log('Failed to fetch my user info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching my user info: $e');
      return null;
    }
  }
  
  /// 批量查询用户信息
  static Future<List<UserInfo>> batchGetUserInfo(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/batchInfo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.token}',
        },
        body: jsonEncode({
          'userIds': userIds,
          'onlyBasicInfo': true,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 处理返回结果
        final users = <UserInfo>[];
        if (data['users'] != null) {
          for (final userJson in data['users']) {
            users.add(UserInfo.fromJson(userJson));
          }
        }
        
        log('Batch fetched ${users.length} users from server');
        return users;
      } else {
        log('Failed to batch fetch users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error batch fetching users: $e');
      return [];
    }
  }
  
  /// 获取好友列表
  static Future<List<UserInfo>> getFriendList({
    int currentPage = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/friend/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.token}',
        },
        body: jsonEncode({
          'userId': ApiConfig.currentUserId,
          'currentPage': currentPage,
          'pageSize': pageSize,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final friends = <UserInfo>[];
        if (data is List) {
          for (final friendJson in data) {
            friends.add(UserInfo(
              userId: friendJson['friendId'] as String,
              userName: friendJson['friendName'] as String,
              userFullName: friendJson['friendFullName'] as String?,
              headImage: friendJson['friendAvatar'] as String?,
              sex: friendJson['friendSex'] as int?,
            ));
          }
        }
        
        log('Fetched ${friends.length} friends from server');
        return friends;
      } else {
        log('Failed to fetch friends: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching friends: $e');
      return [];
    }
  }
  
  /// 获取会话列表
  static Future<List<ChatItem>> getChatList({
    int currentPage = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/chat/lastChatList'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.token}',
        },
        body: jsonEncode({
          'userId': ApiConfig.currentUserId,
          'currentPage': currentPage,
          'pageSize': pageSize,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final chatList = <ChatItem>[];
        if (data is List) {
          for (final chatJson in data) {
            chatList.add(ChatItem.fromJson(chatJson));
          }
        }
        
        log('Fetched ${chatList.length} chats from server');
        return chatList;
      } else {
        log('Failed to fetch chat list: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching chat list: $e');
      return [];
    }
  }
}
