import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/friend.dart';
import '../models/user.dart';
import 'auth_service.dart';

/// 好友管理服务
class FriendService {
  // 单例模式
  static final FriendService _instance = FriendService._internal();
  factory FriendService() => _instance;
  FriendService._internal();

  // API基础URL
  static const String _baseUrl = 'http://120.46.85.43:80';
  static const String _businessPath = '/api';
  
  final AuthService _authService = AuthService();

  /// 搜索用户
  Future<ApiResponse<List<UserSearchResult>>> searchUsers(UserSearchRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl$_businessPath/user/search');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('搜索用户请求: ${request.toJson()}');
      print('搜索用户响应状态: ${response.statusCode}');
      print('搜索用户响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['code'] == 200) {
          List<dynamic> data = jsonData['data'] ?? [];
          List<UserSearchResult> users = data.map((item) => UserSearchResult.fromJson(item)).toList();
          return ApiResponse.success(users);
        } else {
          return ApiResponse.error(jsonData['msg'] ?? '搜索失败');
        }
      } else {
        return ApiResponse.error('搜索失败，请稍后重试');
      }
    } catch (e) {
      print('搜索用户异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 发送好友申请
  Future<ApiResponse<String>> sendFriendRequest(FriendRequestSendRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl$_businessPath/friend/request/send');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('发送好友申请请求: ${request.toJson()}');
      print('发送好友申请响应状态: ${response.statusCode}');
      print('发送好友申请响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['code'] == 200) {
          String requestId = jsonData['data']?.toString() ?? '';
          return ApiResponse.success(requestId);
        } else {
          return ApiResponse.error(jsonData['msg'] ?? '发送好友申请失败');
        }
      } else {
        return ApiResponse.error('发送好友申请失败，请稍后重试');
      }
    } catch (e) {
      print('发送好友申请异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 处理好友申请
  Future<ApiResponse<bool>> handleFriendRequest(FriendRequestHandleRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl$_businessPath/friend/request/handle');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('处理好友申请请求: ${request.toJson()}');
      print('处理好友申请响应状态: ${response.statusCode}');
      print('处理好友申请响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['code'] == 200) {
          bool result = jsonData['data'] ?? false;
          return ApiResponse.success(result);
        } else {
          return ApiResponse.error(jsonData['msg'] ?? '处理好友申请失败');
        }
      } else {
        return ApiResponse.error('处理好友申请失败，请稍后重试');
      }
    } catch (e) {
      print('处理好友申请异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 获取好友申请列表
  Future<ApiResponse<List<FriendRequest>>> getFriendRequestList(FriendRequestListRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl$_businessPath/friend/request/list');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('获取好友申请列表请求: ${request.toJson()}');
      print('获取好友申请列表响应状态: ${response.statusCode}');
      print('获取好友申请列表响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['code'] == 200) {
          List<dynamic> data = jsonData['data'] ?? [];
          List<FriendRequest> requests = data.map((item) => FriendRequest.fromJson(item)).toList();
          return ApiResponse.success(requests);
        } else {
          return ApiResponse.error(jsonData['msg'] ?? '获取好友申请列表失败');
        }
      } else {
        return ApiResponse.error('获取好友申请列表失败，请稍后重试');
      }
    } catch (e) {
      print('获取好友申请列表异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 获取好友列表
  Future<ApiResponse<List<Friend>>> getFriendList(FriendListRequest request) async {
    try {
      final url = Uri.parse('$_baseUrl$_businessPath/friend/list');
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('获取好友列表请求: ${request.toJson()}');
      print('获取好友列表响应状态: ${response.statusCode}');
      print('获取好友列表响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['code'] == 200) {
          List<dynamic> data = jsonData['data'] ?? [];
          List<Friend> friends = data.map((item) => Friend.fromJson(item)).toList();
          return ApiResponse.success(friends);
        } else {
          return ApiResponse.error(jsonData['msg'] ?? '获取好友列表失败');
        }
      } else {
        return ApiResponse.error('获取好友列表失败，请稍后重试');
      }
    } catch (e) {
      print('获取好友列表异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 删除好友
  Future<ApiResponse<bool>> deleteFriend(String userId, String friendId) async {
    try {
      final url = Uri.parse('$_baseUrl$_businessPath/friend/delete');
      final requestBody = {
        'userId': userId,
        'friendId': friendId,
      };
      
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(requestBody),
      );

      print('删除好友请求: $requestBody');
      print('删除好友响应状态: ${response.statusCode}');
      print('删除好友响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['code'] == 200) {
          bool result = jsonData['data'] ?? false;
          return ApiResponse.success(result);
        } else {
          return ApiResponse.error(jsonData['msg'] ?? '删除好友失败');
        }
      } else {
        return ApiResponse.error('删除好友失败，请稍后重试');
      }
    } catch (e) {
      print('删除好友异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 拉黑/取消拉黑好友
  Future<ApiResponse<bool>> blockFriend(String userId, String friendId, int blackFlag) async {
    try {
      final url = Uri.parse('$_baseUrl$_businessPath/friend/block');
      final requestBody = {
        'userId': userId,
        'friendId': friendId,
        'blackFlag': blackFlag,
      };
      
      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(requestBody),
      );

      print('拉黑好友请求: $requestBody');
      print('拉黑好友响应状态: ${response.statusCode}');
      print('拉黑好友响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['code'] == 200) {
          bool result = jsonData['data'] ?? false;
          return ApiResponse.success(result);
        } else {
          return ApiResponse.error(jsonData['msg'] ?? '操作失败');
        }
      } else {
        return ApiResponse.error('操作失败，请稍后重试');
      }
    } catch (e) {
      print('拉黑好友异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 获取我收到的好友申请列表（待处理）
  Future<ApiResponse<List<FriendRequest>>> getReceivedRequests(String userId) async {
    final request = FriendRequestListRequest(
      userId: userId,
      requestType: 2, // 我收到的申请
      currentPage: 1,
      pageSize: 100,
    );
    return getFriendRequestList(request);
  }

  /// 获取我发出的好友申请列表
  Future<ApiResponse<List<FriendRequest>>> getSentRequests(String userId) async {
    final request = FriendRequestListRequest(
      userId: userId,
      requestType: 1, // 我发出的申请
      currentPage: 1,
      pageSize: 100,
    );
    return getFriendRequestList(request);
  }

  /// 接受好友申请
  Future<ApiResponse<bool>> acceptFriendRequest(String requestId, String userId) async {
    final request = FriendRequestHandleRequest(
      requestId: requestId,
      userId: userId,
      handleResult: 1, // 同意
    );
    return handleFriendRequest(request);
  }

  /// 拒绝好友申请
  Future<ApiResponse<bool>> rejectFriendRequest(String requestId, String userId) async {
    final request = FriendRequestHandleRequest(
      requestId: requestId,
      userId: userId,
      handleResult: 2, // 拒绝
    );
    return handleFriendRequest(request);
  }

  /// 快速搜索用户（常用功能封装）
  Future<ApiResponse<List<UserSearchResult>>> quickSearchUsers(String keyword, String currentUserId) async {
    final request = UserSearchRequest(
      keyword: keyword,
      searchType: 2, // 模糊搜索
      currentUserId: currentUserId,
      currentPage: 1,
      pageSize: 20,
    );
    return searchUsers(request);
  }
}
