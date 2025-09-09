import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// 会话列表请求模型
class ConversationListRequest {
  final String userId;
  final int currentPage;
  final int pageSize;

  ConversationListRequest({
    required this.userId,
    this.currentPage = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }
}

// 分页响应模型
class PageResponse<T> {
  final List<T> records;
  final int total;
  final int currentPage;
  final int pageSize;
  final bool hasNext;

  PageResponse({
    required this.records,
    required this.total,
    required this.currentPage,
    required this.pageSize,
    required this.hasNext,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return PageResponse<T>(
      records: (json['records'] as List<dynamic>?)
          ?.map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList() ?? [],
      total: json['total'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      hasNext: json['hasNext'] ?? false,
    );
  }
}

class ConversationService {
  // 单例模式
  static final ConversationService _instance = ConversationService._internal();
  factory ConversationService() => _instance;
  ConversationService._internal();

  // API基础URL - 会话服务的地址，使用您的实际IP地址
  static const String _baseUrl = 'http://192.168.1.5:8083'; 
  static const String _conversationPath = '/hbase/test/send';
  
  final AuthService _authService = AuthService();

  /// 获取会话列表
  Future<ApiResponse<PageResponse<Conversation>>> getConversationList({
    int currentPage = 1,
    int pageSize = 20,
  }) async {
    try {
      // 检查用户是否已登录
      if (!_authService.isLoggedIn || _authService.currentUser == null) {
        return ApiResponse.error('用户未登录');
      }

      final url = Uri.parse('$_baseUrl$_conversationPath');
      final request = ConversationListRequest(
        userId: _authService.currentUser!.id,
        currentPage: currentPage,
        pageSize: pageSize,
      );

      print('获取会话列表请求: ${request.toJson()}');

      final response = await http.post(
        url,
        headers: _authService.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('会话列表响应状态: ${response.statusCode}');
      print('会话列表响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['success'] == true || jsonData['code'] == 200) {
          // 解析分页数据
          final pageData = PageResponse.fromJson(
            jsonData['data'] ?? jsonData,
            (json) => _parseConversationFromJson(json),
          );
          
          return ApiResponse.success(pageData);
        } else {
          return ApiResponse.error(jsonData['message'] ?? '获取会话列表失败');
        }
      } else if (response.statusCode == 401) {
        // Token可能过期，尝试刷新
        final refreshResult = await _authService.refreshToken();
        if (refreshResult.success) {
          // 重新尝试请求
          return getConversationList(currentPage: currentPage, pageSize: pageSize);
        } else {
          return ApiResponse.error('认证失败，请重新登录');
        }
      } else {
        final errorData = jsonDecode(response.body);
        return ApiResponse.error(errorData['message'] ?? '获取会话列表失败，请稍后重试');
      }
    } catch (e) {
      print('获取会话列表异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 刷新会话列表（重新获取第一页）
  Future<ApiResponse<PageResponse<Conversation>>> refreshConversationList() async {
    return getConversationList(currentPage: 1, pageSize: 20);
  }

  /// 搜索会话
  Future<ApiResponse<List<Conversation>>> searchConversations(String keyword) async {
    try {
      if (keyword.trim().isEmpty) {
        return ApiResponse.success([]);
      }

      // 首先获取所有会话
      final result = await getConversationList(pageSize: 100); // 获取更多数据用于搜索
      
      if (result.success && result.data != null) {
        // 在本地进行搜索过滤
        final filteredConversations = result.data!.records
            .where((conversation) => 
                conversation.name.toLowerCase().contains(keyword.toLowerCase()) ||
                conversation.lastMessage.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
        
        return ApiResponse.success(filteredConversations);
      } else {
        return ApiResponse.error(result.message ?? '搜索失败');
      }
    } catch (e) {
      print('搜索会话异常: $e');
      return ApiResponse.error('搜索异常，请稍后重试');
    }
  }

  /// 创建新会话（如果服务器支持）
  Future<ApiResponse<Conversation>> createConversation({
    required String targetUserId,
    required String targetUserName,
    String? targetUserAvatar,
  }) async {
    try {
      // 这里可以实现创建会话的逻辑
      // 目前先创建一个本地会话对象
      final newConversation = Conversation(
        name: targetUserName,
        headImage: targetUserAvatar ?? 'assets/other_headImage.png',
        lastMessage: '',
        timestamp: _formatTimestamp(DateTime.now()),
        userId: targetUserId,
        unreadCount: 0,
      );
      
      return ApiResponse.success(newConversation);
    } catch (e) {
      print('创建会话异常: $e');
      return ApiResponse.error('创建会话失败');
    }
  }

  /// 解析会话数据
  Conversation _parseConversationFromJson(Map<String, dynamic> json) {
    // 根据实际的API响应格式调整字段映射
    return Conversation(
      name: json['conversationName'] ?? json['name'] ?? json['targetUserName'] ?? '未知用户',
      headImage: json['headImage'] ?? json['avatar'] ?? json['targetUserAvatar'] ?? 'assets/other_headImage.png',
      lastMessage: json['lastMessage'] ?? json['lastMsgContent'] ?? '',
      timestamp: _formatTimestamp(_parseTimestamp(json['lastMessageTime'] ?? json['updateTime'])),
      userId: json['targetUserId'] ?? json['userId'] ?? json['conversationId']?.toString() ?? '',
      unreadCount: json['unreadCount'] ?? json['unReadCount'] ?? 0,
    );
  }

  /// 解析时间戳
  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    
    if (timestamp is int) {
      // 如果是毫秒时间戳
      if (timestamp > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        // 如果是秒时间戳
        return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      }
    } else if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }

  /// 格式化时间显示
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // 今天，显示时间
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // 昨天
      return '昨天';
    } else if (difference.inDays < 7) {
      // 一周内，显示星期
      const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
      return '星期${weekdays[dateTime.weekday - 1]}';
    } else if (dateTime.year == now.year) {
      // 同年，显示月日
      return '${dateTime.month}月${dateTime.day}日';
    } else {
      // 不同年，显示年月日
      return '${dateTime.year}年${dateTime.month}月${dateTime.day}日';
    }
  }

  /// 模拟会话数据（用于测试，当真实API不可用时）
  Future<ApiResponse<PageResponse<Conversation>>> getMockConversationList() async {
    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockConversations = [
        Conversation(
          name: '张三',
          headImage: 'assets/other_headImage.png',
          lastMessage: '你好，最近怎么样？',
          timestamp: '10:30',
          userId: 'user_001',
          unreadCount: 2,
        ),
        Conversation(
          name: '李四',
          headImage: 'assets/other_headImage.png',
          lastMessage: '明天见面吧',
          timestamp: '昨天',
          userId: 'user_002',
          unreadCount: 0,
        ),
        Conversation(
          name: '王五',
          headImage: 'assets/other_headImage.png',
          lastMessage: '收到，谢谢！',
          timestamp: '星期二',
          userId: 'user_003',
          unreadCount: 1,
        ),
        Conversation(
          name: '技术交流群',
          headImage: 'assets/other_headImage.png',
          lastMessage: '大家有什么问题可以随时问',
          timestamp: '3月15日',
          userId: 'group_001',
          unreadCount: 5,
        ),
      ];

      final pageResponse = PageResponse<Conversation>(
        records: mockConversations,
        total: mockConversations.length,
        currentPage: 1,
        pageSize: 20,
        hasNext: false,
      );

      return ApiResponse.success(pageResponse);
    } catch (e) {
      return ApiResponse.error('获取模拟数据失败');
    }
  }
}
