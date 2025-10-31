import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xzll_im_flutter_client/constant/app_config.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/api_response.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';

// 会话列表请求模型
class ConversationListRequest {
  final String? msgId;
  final String? url;
  final int? msgCreateTime;
  final String? chatId;
  final int currentPage;
  final int pageSize;
  final String userId;

  ConversationListRequest({
    this.msgId,
    this.url,
    this.msgCreateTime,
    this.chatId,
    this.currentPage = 1,
    this.pageSize = 20,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'msgId': msgId,
      'url': url,
      'msgCreateTime': msgCreateTime,
      'chatId': chatId,
      'currentPage': currentPage,
      'pageSize': pageSize,
      'userId': userId,
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

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageResponse<T>(
      records:
          (json['records'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
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

  // API路径
  static const String _conversationPath = '/im-business/api/chat/lastChatList';
  
  AppData get _appData => Get.find<AppData>();

  /// 获取会话列表
  Future<ApiResponse<List<Conversation>>> getConversationList({
    int currentPage = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$_conversationPath');
      final request = ConversationListRequest(
        userId: _appData.user.value.id,
        currentPage: currentPage,
        pageSize: pageSize,
      );

      info('📤 获取会话列表请求: ${jsonEncode(request.toJson())}');
      info('🔗 请求URL: $url');

      final response = await http.post(
        url,
        headers: _appData.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      info('📥 会话列表响应状态: ${response.statusCode}');
      info('📥 会话列表响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['code'] == 1) {
          final data = jsonData['data'];
          if (data is List) {
            final conversations = data
                .map((json) => _parseConversationFromJson(json))
                .toList();
            info('✅ 成功获取 ${conversations.length} 个会话');
            return ApiResponse.success(conversations);
          } else {
            return ApiResponse.error('数据格式不正确');
          }
        } else {
          return ApiResponse.error(jsonData['msg'] ?? '获取会话列表失败');
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMsg = errorData['error'] ?? errorData['message'] ?? '获取会话列表失败';
          return ApiResponse.error('服务器错误(${response.statusCode}): $errorMsg');
        } catch (e) {
          return ApiResponse.error('获取会话列表失败(${response.statusCode})');
        }
      }
    } catch (e) {
      info('获取会话列表异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 刷新会话列表（重新获取第一页）
  Future<ApiResponse<List<Conversation>>> refreshConversationList() async {
    return getConversationList(currentPage: 1, pageSize: 20);
  }

  /// 解析会话数据
  Conversation _parseConversationFromJson(Map<String, dynamic> json) {
    info('🔍 解析会话数据: $json');
    
    // 根据接口返回字段解析
    final chatId = json['chatId']?.toString() ?? '';
    final userId = json['userId']?.toString() ?? '';
    final lastMsgFormat = json['lastMsgFormat'] ?? 0;
    final lastMessageContent = json['lastMessageContent'] ?? '';
    final lastMsgId = json['lastMsgId']?.toString();
    final lastMsgTime = json['lastMsgTime'];
    final unReadCount = json['unReadCount'] ?? 0;
    
    // 从 chatId 中提取目标用户ID
    final targetUserId = _extractTargetUserIdFromChatId(chatId, userId);
    
    // 格式化最后消息内容（根据消息类型）
    String formattedLastMessage = _formatLastMessage(lastMessageContent, lastMsgFormat);
    
    // 格式化时间戳
    String formattedTimestamp = _formatTimestamp(_parseTimestamp(lastMsgTime));
    
    info('💬 会话ID: $chatId');
    info('👤 目标用户ID: $targetUserId');
    info('💬 最后消息: $formattedLastMessage');
    info('⏰ 时间: $formattedTimestamp');
    info('🔔 未读数: $unReadCount');
    
    return Conversation(
      name: targetUserId ?? '未知用户', // 暂时用ID，后续可以查询用户信息
      headImage: 'assets/other_headImage.png', // 默认头像，后续可以查询用户信息
      lastMessage: formattedLastMessage,
      timestamp: formattedTimestamp,
      userId: userId,
      unreadCount: unReadCount as int,
      targetUserId: targetUserId,
      targetUserName: targetUserId, // 暂时用ID
      targetUserAvatar: null,
      lastMsgFormat: _convertToMessageType(lastMsgFormat),
      lastMsgId: lastMsgId,
      lastMsgTime: lastMsgTime,
      chatId: chatId, // 使用从服务端返回的chatId
    );
  }

  /// 将整数转换为 MessageType
  MessageType _convertToMessageType(int format) {
    switch (format) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.voice;
      case 3:
        return MessageType.video;
      default:
        return MessageType.text;
    }
  }

  /// 从chatId中提取目标用户ID
  String? _extractTargetUserIdFromChatId(String chatId, String currentUserId) {
    if (chatId.isEmpty) return null;
    
    // chatId格式: "100-1-1966369607918948352-1966479049087913984"
    // 需要提取不是当前用户的另一个用户ID
    List<String> parts = chatId.split('-');
    if (parts.length >= 4) {
      final userId1 = parts[2];
      final userId2 = parts[3];
      // 返回不是当前用户的那个ID
      return userId1 == currentUserId ? userId2 : userId1;
    }
    return null;
  }

  /// 格式化最后消息内容
  String _formatLastMessage(String content, int format) {
    if (content.isEmpty) return '';
    
    switch (format) {
      case 0: // 文本消息
        return content;
      case 1: // 图片消息
        return '[图片]';
      case 2: // 语音消息
        return '[语音]';
      case 3: // 视频消息
        return '[视频]';
      case 4: // 文件消息
        return '[文件]';
      case 5: // 位置消息
        return '[位置]';
      default:
        return content;
    }
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

}
