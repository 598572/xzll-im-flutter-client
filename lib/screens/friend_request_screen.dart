import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request.dart';
import '../services/friend_service.dart';
import '../utils/time_utils.dart';

/// 好友申请页面
class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({super.key});

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendService _friendService = FriendService();
  final AppData _authService = Get.find();
  
  List<FriendRequest> _receivedRequests = [];
  List<FriendRequest> _sentRequests = [];
  bool _isLoadingReceived = true;
  bool _isLoadingSent = true;
  String _errorMessageReceived = '';
  String _errorMessageSent = '';
  bool _hasChanges = false; // 标记是否有操作变化

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReceivedRequests();
    _loadSentRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 加载收到的好友申请
  Future<void> _loadReceivedRequests() async {
    final currentUser = _authService.user.value;

    try {
      final response = await _friendService.getReceivedRequests(currentUser.id);
      
      setState(() {
        _isLoadingReceived = false;
        if (response.success && response.data != null) {
          _receivedRequests = response.data!;
          _errorMessageReceived = '';
        } else {
          _receivedRequests = [];
          _errorMessageReceived = response.message ?? '加载收到的申请失败';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingReceived = false;
        _receivedRequests = [];
        _errorMessageReceived = '加载出错: $e';
      });
    }
  }

  /// 加载发出的好友申请
  Future<void> _loadSentRequests() async {
    final currentUser = _authService.user.value;

    try {
      final response = await _friendService.getSentRequests(currentUser.id);
      
      setState(() {
        _isLoadingSent = false;
        if (response.success && response.data != null) {
          _sentRequests = response.data!;
          _errorMessageSent = '';
        } else {
          _sentRequests = [];
          _errorMessageSent = response.message ?? '加载发出的申请失败';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingSent = false;
        _sentRequests = [];
        _errorMessageSent = '加载出错: $e';
      });
    }
  }

  /// 接受好友申请
  Future<void> _acceptRequest(FriendRequest request) async {
    final currentUser = _authService.user.value;

    try {
      final response = await _friendService.acceptFriendRequest(request.requestId, currentUser.id);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已同意好友申请'),
            backgroundColor: Colors.green,
          ),
        );
        _hasChanges = true;
        _loadReceivedRequests(); // 刷新列表
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作出错: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 拒绝好友申请
  Future<void> _rejectRequest(FriendRequest request) async {
    final currentUser = _authService.user.value;

    try {
      final response = await _friendService.rejectFriendRequest(request.requestId, currentUser.id);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已拒绝好友申请'),
            backgroundColor: Colors.orange,
          ),
        );
        _hasChanges = true;
        _loadReceivedRequests(); // 刷新列表
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: ${response.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作出错: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 构建收到的申请项
  Widget _buildReceivedRequestItem(FriendRequest request) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 申请人信息
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: const Icon(Icons.person, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.fromUserName ?? request.fromUserId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${request.fromUserId}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.statusText,
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            // 申请消息
            if (request.requestMessage != null && request.requestMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.requestMessage!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            
            // 申请时间
            const SizedBox(height: 8),
            Text(
              '申请时间: ${TimeUtils.formatDateTime(request.createTime)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            
            // 操作按钮（仅待处理状态显示）
            if (request.isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rejectRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.grey[700],
                        elevation: 0,
                      ),
                      child: const Text('拒绝'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _acceptRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('同意'),
                    ),
                  ),
                ],
              ),
            ] else if (request.handleTime != null) ...[
              const SizedBox(height: 8),
              Text(
                '处理时间: ${TimeUtils.formatDateTime(request.handleTime!)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建发出的申请项
  Widget _buildSentRequestItem(FriendRequest request) {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 申请对象信息
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: const Icon(Icons.person, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.toUserName ?? request.toUserId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${request.toUserId}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.statusText,
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            // 申请消息
            if (request.requestMessage != null && request.requestMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '申请消息: ${request.requestMessage!}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            
            // 申请时间
            const SizedBox(height: 8),
            Text(
              '申请时间: ${TimeUtils.formatDateTime(request.createTime)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            
            // 处理时间
            if (request.handleTime != null) ...[
              const SizedBox(height: 4),
              Text(
                '处理时间: ${TimeUtils.formatDateTime(request.handleTime!)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(int status) {
    switch (status) {
      case 0: // 待处理
        return Colors.orange;
      case 1: // 已同意
        return Colors.green;
      case 2: // 已拒绝
        return Colors.red;
      case 3: // 已过期
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// 构建空状态
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 构建加载状态
  Widget _buildLoadingState() {
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

  /// 构建错误状态
  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('重试', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 返回是否有变化，用于刷新上级页面
        Navigator.of(context).pop(_hasChanges);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('好友申请'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                text: '收到的申请',
                icon: _receivedRequests.where((r) => r.isPending).isNotEmpty
                    ? Badge(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        label: Text(_receivedRequests.where((r) => r.isPending).length.toString()),
                        child: const Icon(Icons.inbox),
                      )
                    : const Icon(Icons.inbox),
              ),
              const Tab(
                text: '发出的申请',
                icon: Icon(Icons.outbox),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // 收到的申请
            RefreshIndicator(
              onRefresh: _loadReceivedRequests,
              child: _buildReceivedRequestsTab(),
            ),
            // 发出的申请
            RefreshIndicator(
              onRefresh: _loadSentRequests,
              child: _buildSentRequestsTab(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建收到的申请标签页
  Widget _buildReceivedRequestsTab() {
    if (_isLoadingReceived) {
      return _buildLoadingState();
    }

    if (_errorMessageReceived.isNotEmpty) {
      return _buildErrorState(_errorMessageReceived, _loadReceivedRequests);
    }

    if (_receivedRequests.isEmpty) {
      return _buildEmptyState('暂无收到的好友申请', Icons.inbox_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _receivedRequests.length,
      itemBuilder: (context, index) {
        return _buildReceivedRequestItem(_receivedRequests[index]);
      },
    );
  }

  /// 构建发出的申请标签页
  Widget _buildSentRequestsTab() {
    if (_isLoadingSent) {
      return _buildLoadingState();
    }

    if (_errorMessageSent.isNotEmpty) {
      return _buildErrorState(_errorMessageSent, _loadSentRequests);
    }

    if (_sentRequests.isEmpty) {
      return _buildEmptyState('暂无发出的好友申请', Icons.outbox_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _sentRequests.length,
      itemBuilder: (context, index) {
        return _buildSentRequestItem(_sentRequests[index]);
      },
    );
  }
}
