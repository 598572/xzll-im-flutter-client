import 'dart:convert';
import 'dart:io';
import "package:web_socket_channel/io.dart";
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';
import 'package:xzll_im_flutter_client/models/enum/message_status.dart';
import 'package:xzll_im_flutter_client/models/enum/message_type.dart';
import '../models/domain/chat_message.dart';
import '../models/domain/conversation.dart';
import 'auth_service.dart';

// WebSocket服务类
class WebSocketService {
  static WebSocketService? _instance;
  WebSocketChannel? _channel;
  String? _currentUserId;
  bool _isConnected = false;
  List<String> _msgIds = [];
  bool _isGettingMsgIds = false;
  String? _cacheFilePath;
  
  // 消息状态回调
  Function(String msgId, MessageStatus status)? onMessageStatusChanged;
  Function(ChatMessage message)? onMessageReceived;
  
  // 会话列表回调
  Function(List<Conversation> conversations)? onConversationsUpdated;
  Function(Conversation conversation)? onConversationUpdated;
  
  // 好友申请推送回调
  Function(FriendRequestPushMessage pushMessage)? onFriendRequestPush;

  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  WebSocketService._() {
    _initCacheFile();
  }

  // 初始化缓存文件路径
  Future<void> _initCacheFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _cacheFilePath = '${directory.path}/msgIds_cache.json';
      info("📁 消息ID缓存文件路径: $_cacheFilePath");
      // 启动时加载缓存
      await _loadMsgIdsFromCache();
    } catch (e) {
      info("❌ 初始化缓存文件失败: $e");
    }
  }

  // 从缓存文件加载消息ID
  Future<void> _loadMsgIdsFromCache() async {
    if (_cacheFilePath == null) return;
    
    try {
      final file = File(_cacheFilePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);
        _msgIds = List<String>.from(data['msgIds'] ?? []);
        info("📂 从缓存加载了 ${_msgIds.length} 个消息ID");
      }
    } catch (e) {
      info("❌ 加载缓存失败: $e");
      _msgIds = [];
    }
  }

  // 保存消息ID到缓存文件
  Future<void> _saveMsgIdsToCache() async {
    if (_cacheFilePath == null) return;
    
    try {
      final file = File(_cacheFilePath!);
      final data = {
        'msgIds': _msgIds,
        'lastUpdate': DateTime.now().millisecondsSinceEpoch,
      };
      await file.writeAsString(jsonEncode(data));
      info("💾 已保存 ${_msgIds.length} 个消息ID到缓存");
    } catch (e) {
      info("❌ 保存缓存失败: $e");
    }
  }

  // 获取单个消息ID（优先从缓存获取）
  Future<String?> getSingleMsgId() async {
    if (!_isConnected || _channel == null) {
      info("❌ WebSocket未连接，尝试重新连接...");
      // 尝试重新连接
      bool reconnected = await _attemptReconnect();
      if (!reconnected) {
        info("❌ 重新连接失败，无法获取消息ID");
        return null;
      }
    }

    // 如果缓存中有消息ID，直接返回
    if (_msgIds.isNotEmpty) {
      String msgId = _msgIds.removeAt(0);
      info("🆔 从缓存获取消息ID: $msgId (剩余: ${_msgIds.length})");
      // 异步保存缓存
      _saveMsgIdsToCache();
      return msgId;
    }

    // 如果缓存为空，从服务器获取一批
    info("🆔 缓存为空，从服务器获取消息ID...");
    await _getMsgIdsFromServer();
    
    if (_msgIds.isNotEmpty) {
      String msgId = _msgIds.removeAt(0);
      info("🆔 从服务器获取到消息ID: $msgId (剩余: ${_msgIds.length})");
      // 异步保存缓存
      _saveMsgIdsToCache();
      return msgId;
    }

    info("❌ 获取消息ID失败");
    return null;
  }

  // 从服务器获取消息ID
  Future<void> _getMsgIdsFromServer() async {
    if (_isGettingMsgIds) {
      // 如果正在获取，等待完成
      int attempts = 0;
      while (_isGettingMsgIds && attempts < 20) {
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }
      return;
    }

    _isGettingMsgIds = true;
    info("🆔 请求从服务器获取消息ID...");
    
    var request = {
      'url': 'xzll/im/c2c/get/batch/msgId',
      'body': {
        'fromUserId': _currentUserId,
      },
    };

    _channel?.sink.add(jsonEncode(request));
    info("📤 发送获取消息ID请求: ${jsonEncode(request)}");
  }

  // 发送消息（使用指定的msgId）
  Future<bool> sendMessageWithId(String msgId, String content, String toUserId) async {
    if (!_isConnected || _channel == null) {
      info("❌ WebSocket未连接，尝试重新连接...");
      // 尝试重新连接
      bool reconnected = await _attemptReconnect();
      if (!reconnected) {
        info("❌ 重新连接失败，无法发送消息");
        return false;
      }
    }

    info("📤 准备发送消息...");
    info("📝 消息内容: $content");
    info("👤 发送给: $toUserId");
    info("�� 使用消息ID: $msgId");
    
    var request = {
      'url': 'xzll/im/c2c/send',
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
    if (!_isConnected || _channel == null) {
      info("❌ WebSocket未连接，无法获取会话列表");
      return;
    }

    info("📋 请求会话列表...");
    var request = {
      'url': 'xzll/im/conversation/list',
      'body': {
        'userId': _currentUserId,
        'page': 1,
        'size': 50,
      },
    };

    _channel?.sink.add(jsonEncode(request));
    info("📤 发送会话列表请求: ${jsonEncode(request)}");
  }

  // 连接WebSocket
  Future<bool> connect(String userId, String token) async {
    try {
      _currentUserId = userId;

      info("🔗 开始连接WebSocket...");
      info("📱 用户ID: $userId");
      info("🔑 Token: $token");

      //url 添加userId参数支持nginx一致性哈希负载均衡
      final wsUrl = 'ws://120.46.85.43:80/websocket?userId=$userId';
      info("🌐 WebSocket连接地址: $wsUrl");

      final headers = {
        'Connection': 'Upgrade',
        'Upgrade': 'websocket',
        'token': token,  // 服务端从ImConstant.TOKEN字段获取
        'uid': userId,   // 用户ID，用于验证
      };

      info("📋 WebSocket请求头: $headers");

      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: headers,
      );

      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          info("❌ WebSocket连接错误: $error");
          _isConnected = false;
        },
        onDone: () {
          info("�� WebSocket连接关闭");
          _isConnected = false;
        },
      );

      _isConnected = true;
      info("✅ WebSocket连接成功");
      // 连接成功后获取消息ID和会话列表
      _getMsgIds();
      requestConversations();
      return true;
    } catch (e) {
      info("❌ WebSocket连接失败: $e");
      _isConnected = false;
      return false;
    }
  }

  // 处理接收到的消息
  void _handleMessage(dynamic message) {
    try {
      info("📨 收到原始消息: $message");
      var response = jsonDecode(message);
      String url = response['url'] ?? '';
      info("🔗 消息URL: $url");

      switch (url) {
        case 'xzll/im/c2c/send':
          _handleC2CSendResponse(response);
          break;
        case 'xzll/im/c2c/receive':
          _handleC2CReceiveMessage(response);
          break;
        case 'xzll/im/c2c/get/batch/msgId':
          _handleGetMsgIdsResponse(response);
          break;
        case 'xzll/im/c2c/response/ack/server/received':
          _handleReceivedAckResponse(response);
          break;
        case 'xzll/im/c2c/response/ack/toUser/unread':
          _handleUnreadAckResponse(response);
          break;
        case 'xzll/im/c2c/response/ack/toUser/read':
          _handleReadAckResponse(response);
          break;
        case 'xzll/im/c2c/withdraw':
          _handleWithdrawResponse(response);
          break;
        case 'xzll/im/conversation/list':
          _handleConversationsResponse(response);
          break;
        case 'xzll/im/conversation/update':
          _handleConversationUpdateResponse(response);
          break;
        case 'xzll/im/friend/request/push':
          _handleFriendRequestPush(response);
          break;
        case 'xzll/im/friend/request/handle/push':
          _handleFriendRequestHandlePush(response);
          break;
        default:
          info("❓ 未知消息类型: $url");
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
      
      // 通知UI更新
      if (onConversationsUpdated != null) {
        onConversationsUpdated!(conversations);
      }
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
        
        // 通知UI更新单个会话
        if (onConversationUpdated != null) {
          onConversationUpdated!(conversation);
        }
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
        
        // 通知UI处理好友申请推送
        if (onFriendRequestPush != null) {
          onFriendRequestPush!(pushMessage);
        }
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
        
        // 通知UI处理好友申请处理结果推送
        if (onFriendRequestPush != null) {
          onFriendRequestPush!(pushMessage);
        }
      }
    } catch (e) {
      info("❌ 解析好友申请处理结果推送失败: $e");
    }
  }

  // 辅助函数：从响应中提取消息ID
  String _extractMsgId(Map<String, dynamic> response) {
    // 优先从 body 中提取消息ID
    if (response['body'] != null && response['body']['msgId'] != null) {
      return response['body']['msgId'].toString();
    }
    // 如果 body 中没有，则从根级别提取
    return response['msgId']?.toString() ?? '';
  }

  // 处理C2C发送消息响应
  void _handleC2CSendResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("✅ 消息发送成功: $msgId");
    
    // 更新消息状态为已发送
    if (onMessageStatusChanged != null) {
      onMessageStatusChanged!(msgId, MessageStatus.serverReceived);
    }
    
    // 模拟接收方发送接收确认
    _simulateReceivedAck(response);
  }

  // 处理接收到的C2C消息
  void _handleC2CReceiveMessage(Map<String, dynamic> response) {
    info("📨 收到新消息: $response");
    
    try {
      // 解析消息内容
      String msgId = response['msgId'] ?? '';
      String fromUserId = response['fromUserId'] ?? '';
      String toUserId = response['toUserId'] ?? '';
      String msgContent = response['msgContent'] ?? '';
      int msgFormat = response['msgFormat'] ?? 0;
      int msgCreateTime = response['msgCreateTime'] ?? DateTime.now().millisecondsSinceEpoch;
      
      info("📨 消息详情: ID=$msgId, 来自=$fromUserId, 内容=$msgContent");
      
      // 创建ChatMessage对象
      ChatMessage message = ChatMessage(
        msgId: msgId,
        content: msgContent,
        fromUserId: fromUserId,
        toUserId: toUserId,
        type: MessageType.fromCode(msgFormat),
        status: MessageStatus.unRead,
        timestamp: DateTime.fromMillisecondsSinceEpoch(msgCreateTime),
      );
      
      // 通知UI有新消息
      if (onMessageReceived != null) {
        onMessageReceived!(message);
      }
      
      // 更新会话列表 - 创建或更新会话
      _updateConversationOnNewMessage(message);
      
      // 发送接收确认
      _sendReceivedAck(msgId, fromUserId, toUserId);
      
    } catch (e) {
      info("❌ 处理接收消息失败: $e");
    }
  }

  // 模拟接收方发送接收确认
  void _simulateReceivedAck(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    
    // 从根级别提取用户ID（因为消息结构是根级别的字段）
    String originalFromUserId = response['fromUserId'] ?? '';
    String originalToUserId = response['toUserId'] ?? '';
    
    // 获取当前用户ID（接收方）
    String currentUserId = _currentUserId ?? '';
    
    info("🔍 ACK调试信息:");
    info("  📨 原始消息发送方: $originalFromUserId");
    info("  📨 原始消息接收方: $originalToUserId");
    info("  👤 当前用户ID: $currentUserId");
    info("  🆔 消息ID: $msgId");
    
    // 延迟发送未读确认
    Future.delayed(Duration(seconds: 1), () {
      var receivedAckRequest = {
        'url': 'xzll/im/c2c/receivedAck',
        'body': {
          'msgId': msgId,
          'fromUserId': currentUserId, // 当前用户（接收方）发送确认
          'toUserId': originalFromUserId, // 原消息发送方
          'msgStatus': 3, // 未读 (UN_R·EAD)
        },
      };
      
      _channel?.sink.add(jsonEncode(receivedAckRequest));
      info("📤 发送未读确认完成: ${jsonEncode(receivedAckRequest)}");
      
      // 延迟发送已读确认
      Future.delayed(Duration(seconds: 2), () {
        var readAckRequest = {
          'url': 'xzll/im/c2c/toUserReadAck',
          'body': {
            'msgId': msgId,
            'fromUserId': currentUserId, // 当前用户（接收方）发送确认
            'toUserId': originalFromUserId, // 原消息发送方
            'msgStatus': 4, // 已读 (READED)
          },
        };
        
        _channel?.sink.add(jsonEncode(readAckRequest));
        info("📤 发送已读确认完成: ${jsonEncode(readAckRequest)}");
        
        // 更新消息状态为已读
        if (onMessageStatusChanged != null) {
          onMessageStatusChanged!(msgId, MessageStatus.readed);
        }
      });
    });
  }

  // 处理获取消息ID响应
  void _handleGetMsgIdsResponse(Map<String, dynamic> response) {
    List<dynamic> msgIds = response['msgIds'] ?? [];
    _msgIds.addAll(msgIds.cast<String>());
    _isGettingMsgIds = false;
    info("🆔 获取到消息ID: ${msgIds.length}个");
    info("📋 消息ID列表: $msgIds");
    // 保存到缓存
    _saveMsgIdsToCache();
  }

  // 处理接收确认响应
  void _handleReceivedAckResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("📥 消息接收确认: $msgId");
    
    // 更新消息状态为已送达
    if (onMessageStatusChanged != null) {
      onMessageStatusChanged!(msgId, MessageStatus.serverReceived);
    }
  }

  // 处理未读确认响应
  void _handleUnreadAckResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("📥 消息未读确认: $msgId");
    
    // 更新消息状态为未读
    if (onMessageStatusChanged != null) {
      onMessageStatusChanged!(msgId, MessageStatus.unRead);
    }
  }

  // 处理已读确认响应
  void _handleReadAckResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("👁️ 消息已读确认: $msgId");
    
    // 更新消息状态为已读
    if (onMessageStatusChanged != null) {
      onMessageStatusChanged!(msgId, MessageStatus.readed);
    }
  }

  // 处理撤回消息响应
  void _handleWithdrawResponse(Map<String, dynamic> response) {
    String msgId = _extractMsgId(response);
    info("🗑️ 消息撤回: $msgId");
  }

  // 获取消息ID
  void _getMsgIds() {
    if (_isGettingMsgIds || _msgIds.isNotEmpty) return;

    info("🆔 请求获取消息ID...");
    _isGettingMsgIds = true;
    var request = {
      'url': 'xzll/im/c2c/get/batch/msgId',
      'body': {
        'fromUserId': _currentUserId,
      },
    };

    _channel?.sink.add(jsonEncode(request));
    info("📤 发送获取消息ID请求: ${jsonEncode(request)}");
  }

  // 发送消息
  Future<bool> sendMessage(String content, String toUserId) async {
    if (!_isConnected || _channel == null) {
      info("❌ WebSocket未连接，尝试重新连接...");
      // 尝试重新连接
      bool reconnected = await _attemptReconnect();
      if (!reconnected) {
        info("❌ 重新连接失败，无法发送消息");
        return false;
      }
    }

    info("📤 准备发送消息...");
    info("📝 消息内容: $content");
    info("👤 发送给: $toUserId");

    // 如果没有消息ID，先获取
    if (_msgIds.isEmpty) {
      info("🆔 消息ID为空，先获取消息ID...");
      _getMsgIds();
      // 等待获取消息ID
      int attempts = 0;
      while (_msgIds.isEmpty && attempts < 10) {
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }
      if (_msgIds.isEmpty) {
        info("❌ 获取消息ID失败");
        return false;
      }
    }

    String msgId = _msgIds.removeAt(0);
    info("🆔 使用消息ID: $msgId");
    
    var request = {
      'url': 'xzll/im/c2c/send',
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

  // 更新会话列表（收到新消息时）
  void _updateConversationOnNewMessage(ChatMessage message) {
    info("📋 更新会话列表 - 收到新消息");
    
    // 创建或更新会话
    Conversation updatedConversation = Conversation(
      name: message.fromUserId, // 暂时使用用户ID，实际应该获取用户名
      headImage: 'assets/other_headImage.png', // 默认头像
      lastMessage: _formatLastMessage(message.content, message.type.code),
      timestamp: _formatTimestamp(message.timestamp),
      userId: message.fromUserId, // 对方用户ID
      unreadCount: 1, // 新消息，未读数量+1
      targetUserId: message.fromUserId,
      targetUserName: message.fromUserId, // 暂时使用用户ID
      targetUserAvatar: 'assets/other_headImage.png',
      lastMsgFormat: message.type.code,
      lastMsgId: message.msgId,
      lastMsgTime: message.timestamp.millisecondsSinceEpoch,
    );
    
    // 通知UI更新会话
    if (onConversationUpdated != null) {
      onConversationUpdated!(updatedConversation);
    }
  }

  // 格式化最后消息内容
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

  // 格式化时间戳
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

  // 发送接收确认
  void sendReceivedAck(String msgId, String fromUserId, String toUserId) {
    info("📥 发送接收确认...");
    var request = {
      'url': 'xzll/im/c2c/receivedAck',
      'body': {
        'msgId': msgId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'msgStatus': 3, // 未读 (UN_READ)
      },
    };
    _channel?.sink.add(jsonEncode(request));
    info("📥 发送接收确认完成: ${jsonEncode(request)}");
  }

  // 内部发送接收确认方法
  void _sendReceivedAck(String msgId, String fromUserId, String toUserId) {
    sendReceivedAck(msgId, toUserId, fromUserId); // 注意参数顺序
  }

  // 发送已读确认
  void sendReadAck(String msgId, String fromUserId, String toUserId) {
    info("👁️ 发送已读确认...");
    var request = {
      'url': 'xzll/im/c2c/toUserReadAck',
      'body': {
        'msgId': msgId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'msgStatus': 4, // 已读 (READED)
      },
    };
    _channel?.sink.add(jsonEncode(request));
    info("👁️ 发送已读确认完成: ${jsonEncode(request)}");
  }

  // 撤回消息
  void withdrawMessage(String msgId, String fromUserId, String toUserId) {
    info("🗑️ 撤回消息...");
    var request = {
      'url': 'xzll/im/c2c/withdraw',
      'body': {
        'msgId': msgId,
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'withdrawFlag': 1, // 撤回
      },
    };
    _channel?.sink.add(jsonEncode(request));
    info("🗑️ 撤回消息完成: ${jsonEncode(request)}");
  }

  // 尝试重新连接
  Future<bool> _attemptReconnect() async {
    if (_currentUserId == null) {
      info("❌ 无法重连：用户ID为空");
      return false;
    }

    info("🔄 尝试重新连接WebSocket...");
    
    // 从AuthService获取最新的token
    final authService = AuthService();
    if (!authService.isLoggedIn || authService.currentUser == null) {
      info("❌ 无法重连：用户未登录");
      return false;
    }

    // 关闭旧连接
    _channel?.sink.close();
    _isConnected = false;

    // 重新连接
    return await connect(_currentUserId!, authService.accessToken ?? '');
  }

  // 检查连接状态
  bool get isConnected => _isConnected;

  // 获取当前用户ID
  String? get currentUserId => _currentUserId;

  // 断开连接
  void disconnect() {
    info("🔌 断开WebSocket连接");
    _channel?.sink.close();
    _isConnected = false;
  }
}
