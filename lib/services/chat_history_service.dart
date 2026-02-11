import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:xzll_im_flutter_client/constant/app_config.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/api_response.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';
import 'package:xzll_im_sdk/xzll_im_sdk.dart';

/// 聊天历史消息请求模型
class ChatHistoryRequest {
  final String chatId;
  final String userId;
  final String? lastMsgId; // 用于分页，获取此消息ID之前的消息
  final int pageSize;
  final int? startTime; // 开始时间戳（可选）
  final int? endTime;   // 结束时间戳（可选）
  final bool reverse;   // 是否倒序查询（默认true，最新消息在前）

  ChatHistoryRequest({
    required this.chatId,
    required this.userId,
    this.lastMsgId,
    this.pageSize = 50,
    this.startTime,
    this.endTime,
    this.reverse = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'userId': userId,
      'lastMsgId': lastMsgId,
      'pageSize': pageSize,
      'startTime': startTime,
      'endTime': endTime,
      'reverse': reverse,
    };
  }
}

/// 聊天历史消息响应模型
class ChatHistoryResponse {
  final List<ChatMessage> messages;
  final bool hasMore;
  final String? nextMsgId;

  ChatHistoryResponse({
    required this.messages,
    required this.hasMore,
    this.nextMsgId,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      messages: (json['messages'] as List<dynamic>?)
          ?.map((item) => _parseMessageFromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      hasMore: json['hasMore'] ?? false,
      nextMsgId: json['nextMsgId'],
    );
  }

  /// 解析服务端消息格式到ChatMessage
  static ChatMessage _parseMessageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      clientMsgId: '', // ✅ 历史消息没有clientMsgId（服务端不存储），设置为空
      msgId: json['msgId']?.toString() ?? '',
      content: json['msgContent'] ?? '',
      fromUserId: json['fromUserId']?.toString() ?? '',
      toUserId: json['toUserId']?.toString() ?? '',
      type: json['msgFormat'] ?? 1,
      status: MessageStatus.readed, // 历史消息默认都是已读状态
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['msgCreateTime'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      chatId: json['chatId']?.toString() ?? '', // 提供默认空字符串
      withdrawStatus: MessageWithdrawStatus.values.firstWhere(
        (status) => status.code == (json['withdrawFlag'] ?? 0),
        orElse: () => MessageWithdrawStatus.no,
      ),
    );
  }
}

/// 聊天历史消息服务
class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  // API路径
  static const String _historyPath = '/im-business/api/chat/c2c/history';
  
  AppData get _appData => Get.find<AppData>();

  /// 获取聊天历史消息
  /// 
  /// [chatId] 聊天ID（格式：userId1-userId2）
  /// [lastMsgId] 最后一条消息ID，用于分页获取更早的消息
  /// [pageSize] 每页消息数量，默认50条
  Future<ApiResponse<ChatHistoryResponse>> getChatHistory({
    required String chatId,
    String? lastMsgId,
    int pageSize = 50,
    int? startTime,
    int? endTime,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$_historyPath');
      final request = ChatHistoryRequest(
        chatId: chatId,
        userId: _appData.user.value.id,
        lastMsgId: lastMsgId,
        pageSize: pageSize,
        startTime: startTime,
        endTime: endTime,
      );

      info('📤 获取历史消息请求: ${jsonEncode(request.toJson())}');
      info('🔗 请求URL: $url');

      final response = await http.post(
        url,
        headers: _appData.getAuthHeaders(),
        body: jsonEncode(request.toJson()),
      );

      info('📥 历史消息响应状态: ${response.statusCode}');
      info('📥 历史消息响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['code'] == 1) {
          final data = jsonData['data'];
          final historyResponse = ChatHistoryResponse.fromJson(data);
          info('✅ 成功获取 ${historyResponse.messages.length} 条历史消息');
          return ApiResponse.success(historyResponse);
        } else {
          return ApiResponse.error(jsonData['msg'] ?? '获取历史消息失败');
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          final errorMsg = errorData['error'] ?? errorData['message'] ?? '获取历史消息失败';
          return ApiResponse.error('服务器错误(${response.statusCode}): $errorMsg');
        } catch (e) {
          return ApiResponse.error('获取历史消息失败(${response.statusCode})');
        }
      }
    } catch (e) {
      info('获取历史消息异常: $e');
      return ApiResponse.error('网络异常，请检查网络连接');
    }
  }

  /// 生成聊天ID（按照服务端逻辑）
  /// 
  /// 根据两个用户ID生成唯一的聊天ID
  /// 
  /// 使用统一的 ChatIdUtils 工具类生成会话ID
  /// 格式：bizType-chatType-smallUserId-bigUserId
  String generateChatId(String userId1, String userId2) {
    return ChatIdUtils.generateC2CChatId(userId1, userId2);
  }

  /// 根据会话信息生成聊天ID
  String generateChatIdFromConversation(String currentUserId, String targetUserId) {
    return ChatIdUtils.generateC2CChatId(currentUserId, targetUserId);
  }
}
