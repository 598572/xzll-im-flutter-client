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
  
  /// 根据会话ID查询聊天记录（用于同步服务器消息）
  static Future<List<Map<String, dynamic>>> getChatMessages({
    required String chatId,
    required String userId,
    int pageSize = 20,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/chat/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.token}',
        },
        body: jsonEncode({
          'chatId': chatId,
          'userId': userId,
          'pageSize': pageSize,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // 适配API响应格式: { "code": 1, "msg": "响应成功", "data": { "messages": [...] } }
        if (responseData != null && responseData['code'] == 1 && responseData['data'] != null) {
          final data = responseData['data'];
          final messages = data['messages'] as List<dynamic>? ?? [];
          
          log('Fetched ${messages.length} messages from server for chatId: $chatId');
          return messages.cast<Map<String, dynamic>>();
        }
        return [];
      } else {
        log('Failed to fetch chat messages: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching chat messages: $e');
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

  /// 根据chatId获取C2C聊天历史记录（用于卸载重装后恢复聊天记录）
  /// 
  /// [chatId] 会话ID，格式：100-1-123729160192-124948567040
  /// 
  /// 返回消息列表，如果失败返回空列表
  static Future<List<Map<String, dynamic>>> getC2CChatHistory({
    required String chatId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/chat/c2c/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.token}',
        },
        body: jsonEncode({
          'chatId': chatId,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // 适配API响应格式: { "code": 1, "msg": "响应成功", "data": { "messages": [...] } }
        if (responseData != null && responseData['code'] == 1 && responseData['data'] != null) {
          final data = responseData['data'];
          final messages = data['messages'] as List<dynamic>? ?? [];
          
          log('Fetched ${messages.length} C2C chat history messages from server for chatId: $chatId');
          return messages.cast<Map<String, dynamic>>();
        } else {
          log('Failed to fetch C2C chat history: ${responseData['msg'] ?? 'Unknown error'}');
          return [];
        }
      } else {
        log('Failed to fetch C2C chat history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching C2C chat history: $e');
      return [];
    }
  }
}
