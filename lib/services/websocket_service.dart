import 'dart:convert';

import 'package:get/get.dart';
import "package:web_socket_channel/io.dart";
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';
import 'package:xzll_im_flutter_client/models/domain/message_status_changed_model.dart';
import 'package:xzll_im_flutter_client/models/enum/handle_type.dart'; // 新增: 使用统一的 HandleType 枚举
import 'package:xzll_im_flutter_client/models/enum/message_status.dart';
import 'package:xzll_im_flutter_client/models/enum/message_type.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';

// WebSocket服务类
class WebSocketService extends GetxService {
  IOWebSocketChannel? _channel;

  final AppData appData = Get.find<AppData>();

  String get _currentUserId => appData.user.value.id;

  Future<void> initWebSocket() async {
    final wsUrl = 'ws://120.46.85.43:80/websocket?userId=$_currentUserId';
    final headers = {
      'Connection': 'Upgrade',
      'Upgrade': 'websocket',
      'token': appData.token.value,
      'uid': _currentUserId,
    };
    try {
      AppEvent.webSocketStatus.sink.add(WebSocketStatus.connecting);
      _channel = IOWebSocketChannel.connect(wsUrl, headers: headers);
      await _channel?.ready;
      AppEvent.webSocketStatus.sink.add(WebSocketStatus.connected);
      _channel?.stream.listen(_onData, onError: _onError, onDone: _onDone);
    } catch (e) {
      error("❌ WebSocket连接失败: $e");
      AppEvent.webSocketStatus.sink.add(WebSocketStatus.error);
    }
  }

  void _onDone() {
    AppEvent.webSocketStatus.sink.add(WebSocketStatus.disconnected);
    info("🔌 WebSocket连接已关闭");
  }

  void _onError(Object e, StackTrace stackTrace) {
    AppEvent.webSocketStatus.sink.add(WebSocketStatus.error);
    error("❌ WebSocket错误: $e  $stackTrace");
  }

  // 从服务器获取消息ID
  Future<void> _getMsgIdsFromServer() async {
    var request = {
      'url': HandleType.c2cGetBatchMsgId.url,
      'body': {'fromUserId': _currentUserId},
    };

    _channel?.sink.add(jsonEncode(request));
    info("📤 发送获取消息ID请求: ${jsonEncode(request)}");
  }

  // 发送消息（使用指定的msgId）
  Future<bool> sendMessageWithId(String msgId, String content, String toUserId) async {
    info("📤 准备发送消息...");
    info("📝 消息内容: $content");
    info("👤 发送给: $toUserId");
    info("�� 使用消息ID: $msgId");

    var request = {
      'url': HandleType.c2cSend.url,
      'body': {
        'msgId': msgId,
        'msgContent': content,
        'toUserId': toUserId,
        'fromUserId': _currentUserId,
        'msgCreateTime': DateTime.now().millisecondsSinceEpoch,
        'msgFormat': 1, // 文本消息
      },
    };

    try {
      _channel!.sink.add(jsonEncode(request));
      info("📤 发送消息成功: ${jsonEncode(request)}");
      return true;
    } catch (e) {
      info("❌ 发送消息失败: $e");
      return false;
    }
  }

  // 请求会话列表
  void requestConversations() {
    info("📋 请求会话列表...");
    var request = {
      'url': HandleType.conversationList.url,
      'body': {'userId': _currentUserId, 'page': 1, 'size': 50},
    };

    _channel?.sink.add(jsonEncode(request));
    info("📤 发送会话列表请求: ${jsonEncode(request)}");
  }

  // 处理接收到的消息
  void _onData(dynamic message) {
    try {
      info("📨 收到原始消息: $message");
      var response = jsonDecode(message);
      String url = response['url'] ?? '';
      info("🔗 消息URL: $url");

      final handleType = HandleType.fromUrl(url);
      if (handleType == null) {
        info("❓ 未知消息类型: $url");
        return;
      }

      switch (handleType) {
        case HandleType.c2cSend:
          _handleC2CSendResponse(response);
          break;
        case HandleType.c2cReceive:
          _handleC2CReceiveMessage(response);
          break;
        case HandleType.c2cGetBatchMsgId:
          _handleGetMsgIdsResponse(response);
          break;
        case HandleType.c2cAckServerReceived:
          _handleReceivedAckResponse(response);
          break;
        case HandleType.c2cAckToUserUnread:
          _handleUnreadAckResponse(response);
          break;
        case HandleType.c2cAckToUserRead:
          _handleReadAckResponse(response);
          break;
        case HandleType.c2cWithdraw:
          _handleWithdrawResponse(response);
          break;
        case HandleType.conversationList:
          _handleConversationsResponse(response);
          break;
        case HandleType.conversationUpdate:
          _handleConversationUpdateResponse(response);
          break;
        case HandleType.friendRequestPush:
          _handleFriendRequestPush(response);
          break;
        case HandleType.friendRequestHandlePush:
          _handleFriendRequestHandlePush(response);
          break;
      }
    } catch (e) {
      info("❌ 处理消息失败: $e");
    }
  }

  // 处理会话列表响应
  void _handleConversationsResponse(Map<String, dynamic> response) {
    info("📋 收到会话列表响应");

    try {
      List<dynamic> conversationData = response['data'] ?? [];
      List<Conversation> conversations = conversationData.map((item) {
        return Conversation.fromJson(item);
      }).toList();

      info("📋 解析到 ${conversations.length} 个会话");

      AppEvent.onConversationsUpdated.add(conversations);

      // 通知UI更新
    } catch (e) {
      info("❌ 解析会话列表失败: $e");
    }
  }

  // 处理会话更新响应
  void _handleConversationUpdateResponse(Map<String, dynamic> response) {
    info("📋 收到会话更新响应");

    try {
      var conversationData = response['data'];
      if (conversationData != null) {
        Conversation conversation = Conversation.fromJson(conversationData);
        info("📋 会话更新: ${conversation.name}");
      }
    } catch (e) {
      info("❌ 解析会话更新失败: $e");
    }
  }

  // 处理好友申请推送
  void _handleFriendRequestPush(Map<String, dynamic> response) {
    info("👥 收到好友申请推送");

    try {
      var pushData = response['body'] ?? response['data'];
      if (pushData != null) {
        FriendRequestPushMessage pushMessage = FriendRequestPushMessage.fromJson(pushData);
        info("👥 好友申请推送: ${pushMessage.pushContent}");
        AppEvent.onFriendRequestPush.add(pushMessage);
      }
    } catch (e) {
      info("❌ 解析好友申请推送失败: $e");
    }
  }

  // 处理好友申请处理结果推送
  void _handleFriendRequestHandlePush(Map<String, dynamic> response) {
    info("👥 收到好友申请处理结果推送");

    try {
      var pushData = response['body'] ?? response['data'];
      if (pushData != null) {
        FriendRequestPushMessage pushMessage = FriendRequestPushMessage.fromJson(pushData);
        info("👥 好友申请处理结果: ${pushMessage.pushContent}");
        AppEvent.onFriendRequestPush.add(pushMessage);
      }
    } catch (e) {
      info("❌ 解析好友申请处理结果推送失败: $e");
    }
  }

  // 辅助函数：从响应中提取消息ID
  String _extractMsgId(Map<String, dynamic> response) {
    if (response['body'] != null && response['body']['msgId'] != null) {
      return response['body']['msgId'].toString();
    }
    return response['msgId']?.toString() ?? '';
  }

  // 处理C2C发送消息响应
  void _handleC2CSendResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("✅ 消息发送成功: $msgId");
    AppEvent.onMessageStatusChanged.add(
      MessageStatusChangedModel(messageId: msgId, messageStatus: MessageStatus.serverReceived),
    );
    _simulateReceivedAck(response);
  }

  // 处理接收到的C2C消息
  void _handleC2CReceiveMessage(Map<String, dynamic> response) {
    info("📨 收到新消息: $response");

    try {
      String msgId = response['msgId'] ?? '';
      String fromUserId = response['fromUserId'] ?? '';
      String toUserId = response['toUserId'] ?? '';
      String msgContent = response['msgContent'] ?? '';
      int msgFormat = response['msgFormat'] ?? 0;
      int msgCreateTime = response['msgCreateTime'] ?? DateTime.now().millisecondsSinceEpoch;

      info("📨 消息详情: ID=$msgId, 来自=$fromUserId, 内容=$msgContent");

      ChatMessage message = ChatMessage(
        msgId: msgId,
        content: msgContent,
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: MessageType.fromCode(msgFormat),
        status: MessageStatus.unRead,
        timestamp: DateTime.fromMillisecondsSinceEpoch(msgCreateTime),
      );

      AppEvent.onMessageReceived.add(message);
      _sendReceivedAck(msgId, fromUserId, toUserId);
      _updateConversationOnNewMessage(message);
    } catch (e) {
      info("❌ 处理接收消息失败: $e");
    }
  }

  // 模拟接收方发送接收确认
  void _simulateReceivedAck(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    String originalFromUserId = response['fromUserId'] ?? '';
    String originalToUserId = response['toUserId'] ?? '';
    String currentUserId = _currentUserId ?? '';

    info("🔍 ACK调试信息:");
    info("  📨 原始消息发送方: $originalFromUserId");
    info("  📨 原始消息接收方: $originalToUserId");
    info("  👤 当前用户ID: $currentUserId");
    info("  🆔 消息ID: $msgId");

    Future.delayed(Duration(seconds: 1), () {
      var receivedAckRequest = {
        'url': HandleType.c2cAckToUserUnread.url.replaceAll(
          '/response/ack/toUser/unread',
          '/receivedAck',
        ), // 保留原路径生成逻辑说明: 直接使用真实发送路径
        // 实际发送路径应为 receivedAck（之前硬编码为 xzll/im/c2c/receivedAck）
        'body': {
          'msgId': msgId,
          'fromUserId': currentUserId,
          'toUserId': originalFromUserId,
          'msgStatus': 3,
        },
      };
      receivedAckRequest['url'] = 'xzll/im/c2c/receivedAck';
      _channel?.sink.add(jsonEncode(receivedAckRequest));
      info("📤 发送未读确认完成: ${jsonEncode(receivedAckRequest)}");

      Future.delayed(Duration(seconds: 2), () {
        var readAckRequest = {
          'url': 'xzll/im/c2c/toUserReadAck', // 该路径未在服务端回执列表里定义，但保持之前逻辑
          'body': {
            'msgId': msgId,
            'fromUserId': currentUserId,
            'toUserId': originalFromUserId,
            'msgStatus': 4,
          },
        };

        _channel?.sink.add(jsonEncode(readAckRequest));
        info("📤 发送已读确认完成: ${jsonEncode(readAckRequest)}");

        AppEvent.onMessageStatusChanged.add(
          MessageStatusChangedModel(messageId: msgId, messageStatus: MessageStatus.readed),
        );
      });
    });
  }

  // 处理获取消息ID响应
  void _handleGetMsgIdsResponse(Map<String, dynamic> response) {
    List<dynamic> msgIds = response['msgIds'] ?? [];
    info("🆔 获取到消息ID: ${msgIds.length}个");
    info("📋 消息ID列表: $msgIds");
  }

  // 处理接收确认响应
  void _handleReceivedAckResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("📥 消息接收确认: $msgId");
    AppEvent.onMessageStatusChanged.add(
      MessageStatusChangedModel(messageId: msgId, messageStatus: MessageStatus.serverReceived),
    );
  }

  // 处理未读确认响应
  void _handleUnreadAckResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("📥 消息未读确认: $msgId");
    AppEvent.onMessageStatusChanged.add(
      MessageStatusChangedModel(messageId: msgId, messageStatus: MessageStatus.unRead),
    );
  }

  // 处理已读确认响应
  void _handleReadAckResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("👁️ 消息已读确认: $msgId");
    AppEvent.onMessageStatusChanged.add(
      MessageStatusChangedModel(messageId: msgId, messageStatus: MessageStatus.readed),
    );
  }

  // 处理撤回消息响应
  void _handleWithdrawResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("🗑️ 消息撤回: $msgId");
  }

  // 获取消息ID
  void _getMsgIds() {
    info("🆔 请求获取消息ID...");
    var request = {
      'url': HandleType.c2cGetBatchMsgId.url,
      'body': {'fromUserId': _currentUserId},
    };

    _channel?.sink.add(jsonEncode(request));
    info("📤 发送获取消息ID请求: ${jsonEncode(request)}");
  }

  // 发送消息
  Future<bool> sendMessage(String content, String toUserId) async {
    String msgId = ""; // TODO: 获取正确的消息ID
    info("🆔 使用消息ID: $msgId");

    var request = {
      'url': HandleType.c2cSend.url,
      'body': {
        'msgId': msgId,
        'msgContent': content,
        'toUserId': toUserId,
        'fromUserId': _currentUserId,
        'msgCreateTime': DateTime.now().millisecondsSinceEpoch,
        'msgFormat': 1,
      },
    };

    try {
      _channel!.sink.add(jsonEncode(request));
      info("📤 发送消息成功: ${jsonEncode(request)}");
      return true;
    } catch (e) {
      info("❌ 发送消息失败: $e");
      return false;
    }
  }

  // 更新会话列表（收到新消息时）
  void _updateConversationOnNewMessage(ChatMessage message) {
    info("📋 更新会话列表 - 收到新消息");

    Conversation updatedConversation = Conversation(
      name: message.fromUserId,
      headImage: 'assets/other_headImage.png',
      lastMessage: _formatLastMessage(message.content, message.type.code),
      timestamp: _formatTimestamp(message.timestamp),
      userId: message.fromUserId,
      unreadCount: 1,
      targetUserId: message.fromUserId,
      targetUserName: message.fromUserId,
      targetUserAvatar: 'assets/other_headImage.png',
      lastMsgFormat: message.type,
      lastMsgId: message.msgId,
      lastMsgTime: message.timestamp.millisecondsSinceEpoch,
    );

    AppEvent.onConversationUpdated.add(updatedConversation);
  }

  String _formatLastMessage(String content, int format) {
    if (content.isEmpty) return '';
    switch (format) {
      case 0:
        return content;
      case 1:
        return '[图片]';
      case 2:
        return '[语音]';
      case 3:
        return '[视频]';
      case 4:
        return '[文件]';
      case 5:
        return '[位置]';
      default:
        return content;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void sendReceivedAck(String msgId, String fromUserId, String toUserId) {
    info("📥 发送接收确认...");
    var request = {
      'url': 'xzll/im/c2c/receivedAck', // 该发送动作没有专门的回执枚举，保持原字符串
      'body': {'msgId': msgId, 'fromUserId': fromUserId, 'toUserId': toUserId, 'msgStatus': 3},
    };
    _channel?.sink.add(jsonEncode(request));
    info("📥 发送接收确认完成: ${jsonEncode(request)}");
  }

  void _sendReceivedAck(String msgId, String fromUserId, String toUserId) {
    sendReceivedAck(msgId, toUserId, fromUserId);
  }

  void sendReadAck(String msgId, String fromUserId, String toUserId) {
    info("👁️ 发送已读确认...");
    var request = {
      'url': 'xzll/im/c2c/toUserReadAck',
      'body': {'msgId': msgId, 'fromUserId': fromUserId, 'toUserId': toUserId, 'msgStatus': 4},
    };
    _channel?.sink.add(jsonEncode(request));
    info("👁️ 发送已读确认完成: ${jsonEncode(request)}");
  }

  void withdrawMessage(String msgId, String fromUserId, String toUserId) {
    info("🗑️ 撤回消息...");
    var request = {
      'url': HandleType.c2cWithdraw.url,
      'body': {'msgId': msgId, 'fromUserId': fromUserId, 'toUserId': toUserId, 'withdrawFlag': 1},
    };
    _channel?.sink.add(jsonEncode(request));
    info("🗑️ 撤回消息完成: ${jsonEncode(request)}");
  }

  void disconnect() {
    info("🔌 断开WebSocket连接");
    _channel?.sink.close();
    AppEvent.webSocketStatus.add(WebSocketStatus.disconnected);
  }
}
