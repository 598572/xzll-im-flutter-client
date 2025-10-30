import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_data.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/friend.dart';
import 'package:xzll_im_flutter_client/models/request/friend_list_request.dart';
import 'package:xzll_im_flutter_client/services/friend_service.dart';

class ContactsLogic extends GetxController {
  final FriendService _friendService = FriendService();
  final AppData _appData = Get.find<AppData>();
  
  /// 暴露appData供视图使用
  AppData get appData => _appData;

  // 响应式变量
  final RxList<Friend> friendList = <Friend>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadFriendList();
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
        friendList.value = response.data!;
        info('加载好友列表成功: ${friendList.length}个好友');
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
}
