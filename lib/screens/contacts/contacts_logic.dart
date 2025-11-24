import 'dart:async';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/friend.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';
import 'package:xzll_im_flutter_client/models/request/friend_list_request.dart';
import 'package:xzll_im_flutter_client/services/friend_service.dart';
import 'package:xzll_im_flutter_client/services/user_info_service.dart';

class ContactsLogic extends GetxController {
  final FriendService _friendService = FriendService();
  final AppData _appData = Get.find<AppData>();
  
  /// 暴露appData供视图使用
  AppData get appData => _appData;

  // 响应式变量
  final RxList<Friend> friendList = <Friend>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadFriendRequestCount = 0.obs;
  
  /// 好友申请推送事件订阅
  StreamSubscription? _friendRequestSubscription;
  
  /// 好友列表刷新事件订阅
  StreamSubscription? _friendListRefreshSubscription;

  @override
  void onInit() {
    super.onInit();
    loadFriendList();
    loadUnreadFriendRequestCount();
    _setupFriendRequestListener();
    _setupFriendListRefreshListener();
  }

  /// 加载好友列表
  Future<void> loadFriendList() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final request = FriendListRequest(
        userId: _appData.user.value.id,
        currentPage: 1,
        pageSize: 100,
      );

      final response = await _friendService.getFriendList(request);

      if (response.success && response.data != null) {
        // ✅ 补充好友的用户信息（头像和昵称）
        final enrichedFriends = await UserInfoService.enrichFriendsWithUserInfo(response.data!);
        friendList.value = enrichedFriends;
        info('加载好友列表成功: ${friendList.length}个好友（已补充用户信息）');
      } else {
        errorMessage.value = response.message ?? '加载好友列表失败';
        error('加载好友列表失败: ${response.message}');
      }
    } catch (e) {
      errorMessage.value = '网络异常，请检查网络连接';
      error('加载好友列表异常: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 刷新好友列表
  Future<void> refreshFriendList() async {
    await loadFriendList();
  }

  /// 搜索好友
  List<Friend> searchFriends(String keyword) {
    if (keyword.isEmpty) return friendList;
    
    return friendList.where((friend) {
      return friend.displayName.toLowerCase().contains(keyword.toLowerCase());
    }).toList();
  }

  /// 按首字母分组好友列表
  Map<String, List<Friend>> get groupedFriends {
    final Map<String, List<Friend>> grouped = {};
    
    for (final friend in friendList) {
      final firstChar = _getFirstChar(friend.displayName);
      if (!grouped.containsKey(firstChar)) {
        grouped[firstChar] = [];
      }
      grouped[firstChar]!.add(friend);
    }
    
    // 按字母排序分组
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedGrouped = <String, List<Friend>>{};
    for (final key in sortedKeys) {
      grouped[key]!.sort((a, b) => a.displayName.compareTo(b.displayName));
      sortedGrouped[key] = grouped[key]!;
    }
    
    return sortedGrouped;
  }

  /// 获取首字母
  String _getFirstChar(String name) {
    if (name.isEmpty) return '#';
    final char = name[0].toUpperCase();
    if (RegExp(r'[A-Z]').hasMatch(char)) {
      return char;
    } else if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(char)) {
      // 中文字符，这里简化处理，实际可以使用拼音库
      return '中';
    } else {
      return '#';
    }
  }

  /// 加载未读好友申请数量
  Future<void> loadUnreadFriendRequestCount() async {
    try {
      final response = await _friendService.getReceivedRequests(_appData.user.value.id);
      
      if (response.success && response.data != null) {
        // 统计状态为0（待处理）的申请数量
        final pendingRequests = response.data!.where((request) => request.status == 0).toList();
        unreadFriendRequestCount.value = pendingRequests.length;
        info('未读好友申请数量: ${unreadFriendRequestCount.value}');
      } else {
        error('加载未读好友申请数量失败: ${response.message}');
      }
    } catch (e) {
      error('加载未读好友申请数量异常: $e');
    }
  }

  /// 设置好友申请推送监听
  void _setupFriendRequestListener() {
    _friendRequestSubscription = AppEvent.onFriendRequestPush.stream.listen((FriendRequestPushMessage pushMessage) {
      info("🔔 通讯录收到好友申请推送: ${pushMessage.pushContent}");
      
      // 如果是新的好友申请，增加未读数量
      if (pushMessage.isNewRequest) {
        unreadFriendRequestCount.value++;
        info("🔄 未读好友申请数量更新为: ${unreadFriendRequestCount.value}");
      }
    });
  }

  /// 设置好友列表刷新监听
  void _setupFriendListRefreshListener() {
    _friendListRefreshSubscription = AppEvent.onFriendListRefresh.stream.listen((bool shouldRefresh) {
      if (shouldRefresh) {
        info("🔄 收到好友列表刷新事件，重新加载好友列表");
        loadFriendList();
      }
    });
  }

  /// 刷新未读数量（在用户查看好友申请后调用）
  void refreshUnreadCount() {
    loadUnreadFriendRequestCount();
  }

  @override
  void onClose() {
    // 清理订阅
    _friendRequestSubscription?.cancel();
    _friendListRefreshSubscription?.cancel();
    super.onClose();
  }
}
