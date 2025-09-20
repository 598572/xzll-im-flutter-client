import 'package:flutter/material.dart';
import 'package:xzll_im_flutter_client/models/domain/user_search_result.dart';
import 'package:xzll_im_flutter_client/models/request/friend_request_send_request.dart';

import '../models/domain/conversation.dart';
import '../services/auth_service.dart';
import '../services/friend_service.dart';

/// 用户搜索页面
class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();
  final AuthService _authService = AuthService();

  List<UserSearchResult> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 执行搜索
  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入搜索关键词')));
      return;
    }

    if (keyword.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('搜索关键词至少需要2个字符')));
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() {
          _errorMessage = '用户未登录';
          _isLoading = false;
        });
        return;
      }

      final response = await _friendService.quickSearchUsers(keyword, currentUser.id);

      setState(() {
        _isLoading = false;
        if (response.success && response.data != null) {
          _searchResults = response.data!;
          _errorMessage = '';
        } else {
          _searchResults = [];
          _errorMessage = response.message ?? '搜索失败';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
        _errorMessage = '搜索出错: $e';
      });
    }
  }

  /// 发送好友申请
  Future<void> _sendFriendRequest(UserSearchResult user) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('用户未登录')));
      return;
    }

    // 显示输入申请消息的对话框
    final requestMessage = await _showRequestMessageDialog();
    if (requestMessage == null) return; // 用户取消了

    try {
      final request = FriendRequestSendRequest(
        fromUserId: currentUser.id,
        toUserId: user.userId,
        requestMessage: requestMessage,
      );

      final response = await _friendService.sendFriendRequest(request);

      if (response.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('好友申请发送成功'), backgroundColor: Colors.green));
        // 刷新搜索结果以更新状态
        _performSearch();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: ${response.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发送出错: $e'), backgroundColor: Colors.red));
    }
  }

  /// 显示输入申请消息的对话框
  Future<String?> _showRequestMessageDialog() async {
    final TextEditingController messageController = TextEditingController();
    messageController.text = '你好，我想添加你为好友';

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发送好友申请'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入申请消息：'),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              maxLines: 3,
              maxLength: 100,
              decoration: const InputDecoration(
                hintText: '输入申请消息...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              final message = messageController.text.trim();
              Navigator.of(context).pop(message.isEmpty ? '你好，我想添加你为好友' : message);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('发送', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 开始聊天
  void _startChat(UserSearchResult user) {
    // 创建临时会话对象
    final conversation = Conversation(
      name: user.displayName,
      headImage: user.headImage ?? 'assets/other_headImage.png',
      lastMessage: '',
      timestamp: '',
      userId: _authService.currentUser?.id ?? '',
      unreadCount: 0,
      targetUserId: user.userId,
      targetUserName: user.displayName,
      targetUserAvatar: user.headImage,
    );
  }

  /// 构建用户项
  Widget _buildUserItem(UserSearchResult user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: user.headImage != null
              ? ClipOval(
                  child: Image.network(
                    user.headImage!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, color: Colors.purple),
                  ),
                )
              : const Icon(Icons.person, color: Colors.purple),
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.phoneHidden != null && user.phoneHidden!.isNotEmpty)
              Text('📱 ${user.phoneHidden}'),
            if (user.emailHidden != null && user.emailHidden!.isNotEmpty)
              Text('📧 ${user.emailHidden}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(user.friendStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.friendStatusText ?? '未知',
                style: TextStyle(
                  color: _getStatusColor(user.friendStatus),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        trailing: _buildActionButton(user),
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(int status) {
    switch (status) {
      case 0: // 非好友
        return Colors.blue;
      case 1: // 已是好友
        return Colors.green;
      case 2: // 待处理
        return Colors.orange;
      case 3: // 已拉黑
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// 构建操作按钮
  Widget _buildActionButton(UserSearchResult user) {
    switch (user.friendStatus) {
      case 0: // 非好友
        return user.canSendRequest
            ? ElevatedButton(
                onPressed: () => _sendFriendRequest(user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: const Size(80, 36),
                ),
                child: const Text('添加好友', style: TextStyle(color: Colors.white, fontSize: 12)),
              )
            : const SizedBox(
                width: 80,
                child: Text(
                  '无法添加',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              );
      case 1: // 已是好友
        return ElevatedButton(
          onPressed: () => _startChat(user),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(80, 36),
          ),
          child: const Text('发消息', style: TextStyle(color: Colors.white, fontSize: 12)),
        );
      case 2: // 待处理
        return const SizedBox(
          width: 80,
          child: Text(
            '申请中',
            style: TextStyle(color: Colors.orange, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        );
      case 3: // 已拉黑
        return const SizedBox(
          width: 80,
          child: Text(
            '已拉黑',
            style: TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        );
      default:
        return const SizedBox(width: 80);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加朋友'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索用户名、手机号、邮箱...',
                      prefixIcon: const Icon(Icons.search, color: Colors.purple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Colors.purple),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('搜索', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          // 搜索结果
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  /// 构建搜索结果区域
  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('输入关键词搜索用户', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 8),
            Text('支持搜索用户名、手机号、邮箱', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.purple)),
            SizedBox(height: 16),
            Text('搜索中...', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('重试', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('没有找到相关用户', style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 8),
            Text('请尝试其他关键词', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return _buildUserItem(_searchResults[index]);
      },
    );
  }
}
