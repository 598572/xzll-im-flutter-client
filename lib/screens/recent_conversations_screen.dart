/*
import 'package:flutter/material.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import '../models/domain/conversation.dart';
import '../services/websocket_service.dart';
import '../services/conversation_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

// 最近会话列表界面（支持长连接实时更新）
class RecentConversationsScreen extends StatefulWidget {
  const RecentConversationsScreen({super.key});

  @override
  State createState() => _RecentConversationsScreenState();
}

class _RecentConversationsScreenState extends State<RecentConversationsScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  bool _isConnected = false;
  final ConversationService _conversationService = ConversationService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _setupWebSocketListeners();
    _loadConversations();
  }

  void _setupWebSocketListeners() {
    // 监听会话列表更新
    WebSocketService.instance.onConversationsUpdated = (List<Conversation> conversations) {
      info("📋 收到会话列表更新: ${conversations.length} 个会话");
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    };

    // 监听单个会话更新
    WebSocketService.instance.onConversationUpdated = (Conversation conversation) {
      info("📋 收到会话更新: ${conversation.name}");
      if (mounted) {
        setState(() {
          // 查找并更新对应的会话
          int index = _conversations.indexWhere((c) => c.userId == conversation.userId);
          if (index != -1) {
            // 更新现有会话，累加未读数量
            Conversation existingConversation = _conversations[index];
            _conversations[index] = Conversation(
              name: conversation.name,
              headImage: conversation.headImage,
              lastMessage: conversation.lastMessage,
              timestamp: conversation.timestamp,
              userId: conversation.userId,
              unreadCount: existingConversation.unreadCount + conversation.unreadCount, // 累加未读数量
              targetUserId: conversation.targetUserId,
              targetUserName: conversation.targetUserName,
              targetUserAvatar: conversation.targetUserAvatar,
              lastMsgFormat: conversation.lastMsgFormat,
              lastMsgId: conversation.lastMsgId,
              lastMsgTime: conversation.lastMsgTime,
              chatId: conversation.chatId, // 保持原有的chatId
            );
          } else {
            // 如果是新会话，添加到列表顶部
            _conversations.insert(0, conversation);
          }
          // 按时间排序
          _conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      }
    };
  }

  /// 加载会话列表
  Future<void> _loadConversations() async {
    if (!_authService.isLoggedIn) {
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // 首先尝试从真实API获取数据
      var result = await _conversationService.getConversationList();
      
      if (result.success && result.data != null) {
        setState(() {
          _conversations = result.data!.records;
          _isLoading = false;
          _isConnected = true;
        });
        info('✅ 成功加载会话列表: ${_conversations.length} 个会话');
      } else {
        // 如果真实API失败，显示错误信息（暂时不使用模拟数据）
        info('❌ 真实API加载失败: ${result.message}');
        setState(() {
          _conversations = [];
          _isLoading = false;
          _isConnected = false;
        });
        info('❌ 加载会话列表失败，请检查网络连接或API配置');
      }

      // 尝试连接WebSocket（用于实时消息更新）
      _connectWebSocket();
      
    } catch (e) {
      info('❌ 加载会话列表异常: $e');
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }

  void _connectWebSocket() async {
    if (!_authService.isLoggedIn || _authService.currentUser == null) {
      return;
    }

    info("🔗 开始连接WebSocket...");
    bool connected = await WebSocketService.instance.connect(
      _authService.currentUser!.id, 
      _authService.accessToken ?? 't_value'
    );
    
    if (connected) {
      info('✅ WebSocket连接成功');
      // 注意：不要在这里再次设置 _isConnected，因为会话列表的连接状态主要看API调用是否成功
    } else {
      info('❌ WebSocket连接失败');
    }
  }

  void _refreshConversations() {
    _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadConversations();
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isConnected) {
      return _buildConnectionError();
    }

    if (_isLoading) {
      return _buildLoading();
    }

    if (_conversations.isEmpty) {
      return _buildEmptyState();
    }

    return _buildConversationsList();
  }

  Widget _buildConnectionError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '连接失败',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '请检查网络连接',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadConversations,
            child: Text('重新加载'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '正在加载会话列表...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            '暂无会话',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '开始与朋友聊天吧',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationItem(conversation);
      },
    );
  }

  Widget _buildConversationItem(Conversation conversation) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(conversation.headImage),
        radius: 24,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (conversation.unreadCount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        conversation.lastMessage,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      onTap: () {
        _navigateToChat(conversation);
      },
    );
  }

  String _formatTime(String timestamp) {
    // 如果已经是格式化的时间字符串，直接返回
    if (timestamp.contains(':') || timestamp.contains('天') || timestamp.contains('昨天') || timestamp.contains('星期')) {
      return timestamp;
    }
    
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      DateTime now = DateTime.now();
      Duration difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } catch (e) {
      return timestamp;
    }
  }

  void _navigateToChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversation: conversation),
      ),
    );
  }

  @override
  void dispose() {
    // 清理回调
    WebSocketService.instance.onConversationsUpdated = null;
    WebSocketService.instance.onConversationUpdated = null;
    super.dispose();
  }
}
*/
