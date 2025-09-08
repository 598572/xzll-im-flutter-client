import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../services/websocket_service.dart';
import 'chat_screen.dart';

// 最近会话列表界面（支持长连接实时更新）
class RecentConversationsScreen extends StatefulWidget {
  @override
  _RecentConversationsScreenState createState() => _RecentConversationsScreenState();
}

class _RecentConversationsScreenState extends State<RecentConversationsScreen> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _setupWebSocketListeners();
    _connectWebSocket();
  }

  void _setupWebSocketListeners() {
    // 监听会话列表更新
    WebSocketService.instance.onConversationsUpdated = (List<Conversation> conversations) {
      print("📋 收到会话列表更新: ${conversations.length} 个会话");
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    };

    // 监听单个会话更新
    WebSocketService.instance.onConversationUpdated = (Conversation conversation) {
      print("📋 收到会话更新: ${conversation.name}");
      setState(() {
        // 查找并更新对应的会话
        int index = _conversations.indexWhere((c) => c.userId == conversation.userId);
        if (index != -1) {
          _conversations[index] = conversation;
        } else {
          // 如果是新会话，添加到列表顶部
          _conversations.insert(0, conversation);
        }
        // 按时间排序
        _conversations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    };
  }

  void _connectWebSocket() async {
    print("🔗 开始连接WebSocket...");
    bool connected = await WebSocketService.instance.connect('111', 't_value');
    setState(() {
      _isConnected = connected;
    });
    
    if (connected) {
      print('✅ WebSocket连接成功，等待会话列表数据...');
    } else {
      print('❌ WebSocket连接失败');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refreshConversations() {
    setState(() {
      _isLoading = true;
    });
    WebSocketService.instance.requestConversations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshConversations();
          // 等待一段时间让数据加载
          await Future.delayed(Duration(seconds: 1));
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
            onPressed: _connectWebSocket,
            child: Text('重新连接'),
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
          SizedBox(height: 4),
          // 连接状态指示器
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
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
