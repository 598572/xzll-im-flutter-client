/*
import 'package:flutter/material.dart';
import 'package:xzll_im_flutter_client/constant/constant.dart';
import 'package:xzll_im_flutter_client/models/request/friend_list_request.dart';
import '../models/domain/friend.dart';
import '../models/domain/conversation.dart';
import '../services/friend_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';
import 'user_search_screen.dart';
import 'friend_request_screen.dart';

/// 好友列表页面
class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  final FriendService _friendService = FriendService();
  final AuthService _authService = AuthService();
  
  List<Friend> _friends = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _pendingRequestCount = 0;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadPendingRequestCount();
  }

  /// 加载好友列表
  Future<void> _loadFriends() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      setState(() {
        _errorMessage = '用户未登录';
        _isLoading = false;
      });
      return;
    }

    try {
      final request = FriendListRequest(userId: currentUser.id);
      final response = await _friendService.getFriendList(request);
      
      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _friends = response.data!;
          _errorMessage = '';
        } else {
          _friends = [];
          _errorMessage = response.message ?? '加载好友列表失败';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _friends = [];
        _errorMessage = '加载出错: $e';
      });
    }
  }

  /// 加载待处理的好友申请数量
  Future<void> _loadPendingRequestCount() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      final response = await _friendService.getReceivedRequests(currentUser.id);
      if (response.success && response.data != null) {
        final pendingRequests = response.data!.where((request) => request.isPending).toList();
        setState(() {
          _pendingRequestCount = pendingRequests.length;
        });
      }
    } catch (e) {
      error('加载待处理申请数量失败: $e');
    }
  }

  /// 删除好友
  Future<void> _deleteFriend(Friend friend) async {
    final confirmed = await _showDeleteConfirmDialog(friend);
    if (!confirmed) return;

    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    try {
      final response = await _friendService.deleteFriend(currentUser.id, friend.friendId);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('好友删除成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadFriends(); // 刷新列表
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('删除出错: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 拉黑/取消拉黑好友
  Future<void> _toggleBlockFriend(Friend friend) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final isBlocking = !(friend.blackFlag ?? false);
    final action = isBlocking ? '拉黑' : '取消拉黑';
    
    final confirmed = await _showBlockConfirmDialog(friend, isBlocking);
    if (!confirmed) return;

    try {
      final response = await _friendService.blockFriend(
        currentUser.id, 
        friend.friendId, 
        isBlocking ? 1 : 0
      );
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$action成功'),
            backgroundColor: Colors.green,
          ),
        );
        _loadFriends(); // 刷新列表
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$action失败: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$action出错: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 显示删除确认对话框
  Future<bool> _showDeleteConfirmDialog(Friend friend) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除好友'),
        content: Text('确定要删除好友 "${friend.displayName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  /// 显示拉黑确认对话框
  Future<bool> _showBlockConfirmDialog(Friend friend, bool isBlocking) async {
    final action = isBlocking ? '拉黑' : '取消拉黑';
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$action好友'),
        content: Text('确定要${action}好友 "${friend.displayName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action, style: TextStyle(color: isBlocking ? Colors.red : Colors.green)),
          ),
        ],
      ),
    ) ?? false;
  }

  /// 开始聊天
  void _startChat(Friend friend) {
    // 创建临时会话对象
    final conversation = Conversation(
      name: friend.displayName,
      headImage: friend.friendHeadImage ?? 'assets/other_headImage.png',
      lastMessage: '',
      timestamp: '',
      userId: _authService.currentUser?.id ?? '',
      unreadCount: 0,
      targetUserId: friend.friendId,
      targetUserName: friend.displayName,
      targetUserAvatar: friend.friendHeadImage,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversation: conversation),
      ),
    );
  }

  /// 显示好友操作菜单
  void _showFriendMenu(Friend friend) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 好友信息
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withOpacity(0.1),
                child: friend.friendHeadImage != null
                    ? ClipOval(
                        child: Image.network(
                          friend.friendHeadImage!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.person, color: Colors.purple),
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.purple),
              ),
              title: Text(friend.displayName),
              subtitle: Text('用户ID: ${friend.friendId}'),
            ),
            const Divider(),
            
            // 操作选项
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('发消息'),
              onTap: () {
                Navigator.pop(context);
                _startChat(friend);
              },
            ),
            ListTile(
              leading: Icon(
                friend.blackFlag == true ? Icons.person : Icons.block,
                color: friend.blackFlag == true ? Colors.green : Colors.orange,
              ),
              title: Text(friend.blackFlag == true ? '取消拉黑' : '拉黑'),
              onTap: () {
                Navigator.pop(context);
                _toggleBlockFriend(friend);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除好友'),
              onTap: () {
                Navigator.pop(context);
                _deleteFriend(friend);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建好友项
  Widget _buildFriendItem(Friend friend) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: friend.friendHeadImage != null
              ? ClipOval(
                  child: Image.network(
                    friend.friendHeadImage!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.person, color: Colors.purple),
                  ),
                )
              : const Icon(Icons.person, color: Colors.purple),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                friend.displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            if (friend.blackFlag == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '已拉黑',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: friend.friendUserName != null
            ? Text(
                '用户名: ${friend.friendUserName}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.grey),
          onPressed: () => _showFriendMenu(friend),
        ),
        onTap: () => _startChat(friend),
      ),
    );
  }

  /// 构建功能入口项
  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
    int? badge,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: (iconColor ?? Colors.purple).withOpacity(0.1),
              child: Icon(icon, color: iconColor ?? Colors.purple),
            ),
            if (badge != null && badge > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badge > 99 ? '99+' : badge.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null 
            ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通讯录'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserSearchScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadFriends();
          await _loadPendingRequestCount();
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            SizedBox(height: 16),
            Text(
              '加载中...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFriends,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('重试', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // 功能入口
        _buildFunctionItem(
          icon: Icons.person_add,
          title: '添加朋友',
          subtitle: '通过搜索添加新朋友',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserSearchScreen()),
            );
          },
        ),
        _buildFunctionItem(
          icon: Icons.notifications,
          title: '好友申请',
          subtitle: '查看收到的好友申请',
          badge: _pendingRequestCount,
          iconColor: Colors.orange,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FriendRequestScreen()),
            );
            // 如果从好友申请页面返回，刷新数据
            if (result == true) {
              _loadFriends();
              _loadPendingRequestCount();
            }
          },
        ),
        
        if (_friends.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '我的好友 (${_friends.length})',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // 好友列表
          ..._friends.map((friend) => _buildFriendItem(friend)),
        ] else ...[
          const SizedBox(height: 40),
          const Center(
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '还没有好友',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  '快去添加一些朋友吧！',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
*/
