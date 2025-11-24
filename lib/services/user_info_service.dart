import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/api_constants.dart';
import '../constant/app_data.dart';
import '../constant/custom_log.dart';
import '../models/user_info.dart';
import '../models/domain/conversation.dart';
import '../models/domain/friend.dart';
import 'user_cache_service.dart';

/// 用户信息服务
/// 负责批量获取用户信息，支持缓存策略
class UserInfoService {
  /// 批量获取用户信息（集成本地缓存）
  static Future<Map<String, UserInfo>> batchGetUserInfo(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    
    try {
      // ✅ 初始化缓存服务
      final cacheService = UserCacheService.instance;
      await cacheService.initialize();
      
      info('📤 批量获取用户信息: ${userIds.length}个用户');
      info('📋 用户ID列表: $userIds');
      
      // ✅ 第一步：从缓存中获取已有的用户信息
      final Map<String, UserInfo> result = {};
      final List<String> missingUserIds = [];
      
      for (final userId in userIds) {
        final cachedUserInfo = await cacheService.getUserInfo(userId);
        if (cachedUserInfo != null) {
          result[userId] = cachedUserInfo;
          info('💾 从缓存获取用户信息: ${cachedUserInfo.userName}');
        } else {
          missingUserIds.add(userId);
        }
      }
      
      // ✅ 第二步：批量从服务器获取缺失的用户信息
      if (missingUserIds.isNotEmpty) {
        info('🌐 需要从服务器获取 ${missingUserIds.length} 个用户信息');
        
        final AppData appData = Get.find<AppData>();
        
        // ✅ 构建请求数据
        final requestData = {
          'userIds': missingUserIds,
          'onlyBasicInfo': true, // 只获取基础信息（昵称、头像）
        };
        
        // ✅ 调用批量用户信息API
        final response = await http.post(
          Uri.parse(ApiConstants.userBatchInfo),
          headers: {
            ...appData.getAuthHeaders(),
            'Content-Type': 'application/json',
          },
          body: json.encode(requestData),
        );
        
        info('📥 批量用户信息响应状态码: ${response.statusCode}');
        info('📥 批量用户信息响应内容: ${response.body}');
        
        if (response.statusCode == 200) {
          try {
            final responseData = json.decode(response.body);
            
            // ✅ 检查服务器响应格式 {"code": 1, "msg": "success", "data": {"users": [...], "notFoundUserIds": []}}
            if (responseData is Map<String, dynamic> && responseData['code'] == 1) {
              final data = responseData['data'];
              final List<UserInfo> newUserInfos = [];
              
              // ✅ 处理新的数据格式：data.users
              if (data is Map<String, dynamic> && data['users'] is List) {
                final usersList = data['users'] as List;
                for (final userJson in usersList) {
                  if (userJson is Map<String, dynamic>) {
                    try {
                      final userInfo = UserInfo.fromJson(userJson);
                      result[userInfo.userId] = userInfo;
                      newUserInfos.add(userInfo);
                      info('✅ 解析用户信息成功: ${userInfo.userId} - ${userInfo.userName}');
                    } catch (e) {
                      error('❌ 解析用户信息失败: $e, 数据: $userJson');
                    }
                  }
                }
                
                // ✅ 记录未找到的用户ID
                if (data['notFoundUserIds'] is List) {
                  final notFoundIds = data['notFoundUserIds'] as List;
                  if (notFoundIds.isNotEmpty) {
                    info('⚠️ 未找到的用户ID: $notFoundIds');
                  }
                }
              } else {
                error('❌ 批量用户信息响应格式错误: data不是预期的格式');
                error('❌ 实际data格式: $data');
              }
              
              // ✅ 第三步：将新获取的用户信息存储到本地缓存
              if (newUserInfos.isNotEmpty) {
                await _updateUserInfoCache(newUserInfos);
                info('💾 已将 ${newUserInfos.length} 个用户信息存储到本地缓存');
              }
              
              info('✅ 成功获取 ${result.length} 个用户信息（缓存: ${result.length - newUserInfos.length}, 服务器: ${newUserInfos.length}）');
            } else {
              error('❌ 服务器返回错误: ${responseData['msg'] ?? '未知错误'}');
            }
          } catch (e) {
            error('❌ 解析批量用户信息响应失败: $e');
            error('❌ 原始响应: ${response.body}');
          }
        } else {
          error('❌ 批量获取用户信息请求失败，状态码: ${response.statusCode}');
          error('❌ 响应内容: ${response.body}');
        }
      }
      
      return result;
    } catch (e, stackTrace) {
      error('❌ 批量获取用户信息异常: $e');
      error('❌ 堆栈跟踪: $stackTrace');
      return {};
    }
  }

  /// 更新用户信息缓存
  static Future<void> _updateUserInfoCache(List<UserInfo> userInfos) async {
    try {
      final cacheService = UserCacheService.instance;
      
      // 批量更新缓存
      for (final userInfo in userInfos) {
        await cacheService.updateUserInfo(userInfo.userId, userInfo);
      }
      
      info('💾 成功更新 ${userInfos.length} 个用户信息到缓存');
    } catch (e) {
      error('❌ 更新用户信息缓存失败: $e');
    }
  }

  /// 获取单个用户信息
  static Future<UserInfo?> getUserInfo(String userId) async {
    if (userId.isEmpty) return null;
    
    final result = await batchGetUserInfo([userId]);
    return result[userId];
  }

  /// 为会话列表补充用户信息
  static Future<List<Conversation>> enrichConversationsWithUserInfo(
    List<Conversation> conversations,
  ) async {
    if (conversations.isEmpty) return conversations;
    
    // ✅ 提取需要查询用户信息的用户ID
    final userIds = conversations
        .where((conv) => conv.targetUserId?.isNotEmpty == true)
        .map((conv) => conv.targetUserId!)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    
    if (userIds.isEmpty) return conversations;
    
    info('🔍 为 ${conversations.length} 个会话补充用户信息，涉及 ${userIds.length} 个用户');
    info('🔍 需要查询的用户ID列表: $userIds');
    
    // ✅ 批量获取用户信息
    info('🔍 开始调用batchGetUserInfo，参数: $userIds');
    final userInfoMap = await batchGetUserInfo(userIds);
    info('🔍 批量获取到的用户信息: ${userInfoMap.keys.toList()}');
    info('🔍 用户信息详情: $userInfoMap');
    
    // ✅ 为会话列表补充用户信息
    final enrichedConversations = conversations.map((conversation) {
      final userId = conversation.targetUserId;
      info('🔍 处理会话 - targetUserId: $userId');
      
      if (userId != null && userInfoMap.containsKey(userId)) {
        final userInfo = userInfoMap[userId]!;
        info('✅ 找到用户信息 - userName: ${userInfo.userName}, userFullName: ${userInfo.userFullName}, headImage: ${userInfo.headImage}');
        
        return conversation.copyWith(
          targetUserName: userInfo.userFullName ?? userInfo.userName,
          targetUserAvatar: userInfo.headImage,
        );
      } else {
        info('❌ 未找到用户信息 - userId: $userId, 可用的用户ID: ${userInfoMap.keys.toList()}');
      }
      return conversation; // 没有找到用户信息，保持原样
    }).toList();
    
    info('✅ 成功为 ${enrichedConversations.length} 个会话补充用户信息');
    return enrichedConversations;
  }

  /// 为好友列表补充用户信息（如果Friend模型中信息不完整）
  static Future<List<Friend>> enrichFriendsWithUserInfo(
    List<Friend> friends,
  ) async {
    if (friends.isEmpty) return friends;
    
    // ✅ 找出信息不完整的好友（没有头像或昵称）
    final incompleteUserIds = friends
        .where((friend) => 
            friend.friendAvatar?.isEmpty != false || 
            friend.friendFullName?.isEmpty != false)
        .map((friend) => friend.friendId)
        .toList();
    
    if (incompleteUserIds.isEmpty) {
      info('✅ 所有好友信息都完整，无需补充');
      return friends;
    }
    
    info('🔍 为 ${incompleteUserIds.length} 个好友补充用户信息');
    
    // ✅ 批量获取用户信息
    final userInfoMap = await batchGetUserInfo(incompleteUserIds);
    
    // ✅ 为好友列表补充用户信息
    final enrichedFriends = friends.map((friend) {
      if (userInfoMap.containsKey(friend.friendId)) {
        final userInfo = userInfoMap[friend.friendId]!;
        return Friend(
          friendId: friend.friendId,
          friendName: friend.friendName ?? userInfo.userName,
          friendFullName: friend.friendFullName ?? userInfo.userFullName,
          friendAvatar: friend.friendAvatar ?? userInfo.headImage,
          friendSex: friend.friendSex ?? userInfo.sex,
          blackFlag: friend.blackFlag,
          createTime: friend.createTime,
        );
      }
      return friend; // 没有找到用户信息，保持原样
    }).toList();
    
    info('✅ 成功为好友列表补充用户信息');
    return enrichedFriends;
  }
}
