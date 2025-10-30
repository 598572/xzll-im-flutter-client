import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';
import 'package:xzll_im_flutter_client/services/friend_service.dart';
import 'package:xzll_im_flutter_client/utils/time_utils.dart';

/// 新的朋友（好友请求列表）：待处理 / 已处理
class NewFriendsScreen extends StatefulWidget {
  const NewFriendsScreen({super.key});

  @override
  State<NewFriendsScreen> createState() => _NewFriendsScreenState();
}

class _NewFriendsScreenState extends State<NewFriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FriendService _friendService = FriendService();
  final AppData _appData = Get.find<AppData>();

  List<FriendRequest> _pending = [];
  List<FriendRequest> _processed = [];
  bool _loading = true;
  String _error = '';

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _sub = AppEvent.onFriendRequestPush.stream
        .listen((FriendRequestPushMessage push) {
      info("🔔 新的朋友收到推送，刷新: ${push.pushContent}");
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await _friendService.getReceivedRequests(_appData.user.value.id);
      if (res.success && res.data != null) {
        final all = res.data!;
        _pending = all.where((e) => e.isPending).toList();
        _processed = all.where((e) => !e.isPending).toList();
      } else {
        _pending = [];
        _processed = [];
        _error = res.message ?? '加载失败';
      }
    } catch (e) {
      _error = '网络异常: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _accept(FriendRequest req) async {
    final res = await _friendService.acceptFriendRequest(req.requestId, _appData.user.value.id);
    if (res.success) {
      Get.snackbar('已同意', '已同意 ${req.fromUserName ?? req.fromUserId} 的请求');
      _loadData();
    } else {
      Get.snackbar('操作失败', res.message ?? '请稍后重试');
    }
  }

  Future<void> _reject(FriendRequest req) async {
    final res = await _friendService.rejectFriendRequest(req.requestId, _appData.user.value.id);
    if (res.success) {
      Get.snackbar('已拒绝', '已拒绝 ${req.fromUserName ?? req.fromUserId} 的请求');
      _loadData();
    } else {
      Get.snackbar('操作失败', res.message ?? '请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新的朋友'),
        bottom: const TabBar(
          tabs: [
            Tab(text: '待处理'),
            Tab(text: '已处理'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? _buildError()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPendingList(),
                    _buildProcessedList(),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(_error, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loadData, child: const Text('重试')),
        ],
      ),
    );
  }

  Widget _buildPendingList() {
    if (_pending.isEmpty) {
      return _buildEmpty('暂无待处理请求', Icons.inbox_outlined);
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _pending.length,
        itemBuilder: (context, index) => _buildRequestTile(_pending[index], true),
      ),
    );
  }

  Widget _buildProcessedList() {
    if (_processed.isEmpty) {
      return _buildEmpty('暂无已处理请求', Icons.mark_email_read_outlined);
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _processed.length,
        itemBuilder: (context, index) => _buildRequestTile(_processed[index], false),
      ),
    );
  }

  Widget _buildEmpty(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.grey),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRequestTile(FriendRequest req, bool pending) {
    return ListTile(
      leading: CircleAvatar(child: Text((req.fromUserName ?? req.fromUserId).characters.first)),
      title: Text(req.fromUserName ?? req.fromUserId),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (req.requestMessage != null && req.requestMessage!.isNotEmpty)
            Text(req.requestMessage!),
          const SizedBox(height: 2),
          Text(TimeUtils.formatDateTime(req.createTime), style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      trailing: pending
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(onPressed: () => _reject(req), child: const Text('拒绝')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () => _accept(req), child: const Text('同意')),
              ],
            )
          : Text(req.statusText, style: const TextStyle(color: Colors.grey)),
    );
  }
}


