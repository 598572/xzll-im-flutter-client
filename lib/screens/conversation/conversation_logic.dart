import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/constant/custom_log.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/services/conversation_service.dart';
import 'package:xzll_im_flutter_client/services/websocket_service.dart';

class ConversationLogic extends GetxController {
  final WebSocketService webSocketService = Get.find<WebSocketService>();
  final ConversationService _conversationService = ConversationService();

  ///会话列表
  final RxList<Conversation> conversationList = <Conversation>[].obs;
  
  /// 加载状态
  final RxBool isLoading = false.obs;
  
  /// 错误信息
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    AppEvent.onConversationsUpdated.listen(onConversationsUpdate);
    AppEvent.onConversationUpdated.listen(onConversationUpdate);
    // 加载会话列表
    loadConversations();
  }
  
  /// 加载会话列表
  Future<void> loadConversations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      info('📥 开始加载会话列表...');
      
      final response = await _conversationService.getConversationList();
      
      if (response.success && response.data != null) {
        conversationList.assignAll(response.data!);
        info('✅ 成功加载 ${conversationList.length} 个会话');
      } else {
        errorMessage.value = response.message ?? '加载失败';
        info('❌ 加载会话列表失败: ${errorMessage.value}');
      }
    } catch (e) {
      errorMessage.value = '加载异常: $e';
      info('❌ 加载会话列表异常: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 刷新会话列表
  Future<void> refreshConversations() async {
    await loadConversations();
  }

  void onConversationsUpdate(List<Conversation> data) {
    conversationList.assignAll(data);
  }

  void onConversationUpdate(Conversation data) {
    int index = conversationList.indexWhere(
      (element) => element.userId == data.userId && element.targetUserId == data.targetUserId,
    );
    if (index != -1) {
      conversationList[index] = data;
      conversationList.refresh();
    } else {
      conversationList.add(data);
    }
  }

  /// 跳转到搜索用户页面（添加好友）
  void goToAddFriend() {
    Get.toNamed(RouterName.userSearch);
  }

  /// 创建群聊
  void createGroupChat() {
    // TODO: 实现创建群聊功能
    Get.snackbar('提示', '群聊功能开发中...');
  }

  /// 扫一扫
  void scanQRCode() {
    // TODO: 实现扫一扫功能
    Get.snackbar('提示', '扫一扫功能开发中...');
  }

  /// 打开聊天界面
  void openChat(Conversation conversation) {
    info('🚀 准备打开聊天界面: ${conversation.targetUserName}');
    
    // 检查必要参数
    if (conversation.targetUserId == null || conversation.targetUserId!.isEmpty) {
      Get.snackbar('错误', '无法打开聊天，缺少目标用户信息');
      return;
    }
    
    // 跳转到聊天界面，并传递会话参数
    Get.toNamed(RouterName.chat, arguments: conversation);
  }
}
