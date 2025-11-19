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
        // ✅ 去重处理：如果服务端返回了重复的会话，只保留一个
        List<Conversation> serverList = _deduplicateConversations(response.data!);
        
        // ✅ 智能合并：保留本地和服务器数据中时间戳更新的那个
        List<Conversation> mergedList = _mergeConversations(conversationList, serverList);
        conversationList.assignAll(mergedList);
        
        info('✅ 成功加载 ${conversationList.length} 个会话（服务器: ${response.data!.length}）');
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
  
  /// 去重会话列表（使用 chatId 作为唯一标识）
  List<Conversation> _deduplicateConversations(List<Conversation> conversations) {
    Map<String, Conversation> uniqueMap = {};
    
    for (var conversation in conversations) {
      // ✅ 只使用 chatId 作为唯一标识
      if (conversation.chatId == null || conversation.chatId!.isEmpty) {
        waring('⚠️ 会话缺少 chatId，跳过: ${conversation.targetUserName ?? conversation.userId}');
        continue;
      }
      
      String chatId = conversation.chatId!;
      
      // 如果已经存在相同 chatId，选择最新的会话（根据时间戳）
      if (uniqueMap.containsKey(chatId)) {
        var existing = uniqueMap[chatId]!;
        // 比较时间戳，保留最新的
        if (conversation.lastMsgTime != null && existing.lastMsgTime != null) {
          if (conversation.lastMsgTime! > existing.lastMsgTime!) {
            uniqueMap[chatId] = conversation;
            info('🔄 替换旧会话: $chatId (时间更新)');
          }
        }
      } else {
        uniqueMap[chatId] = conversation;
      }
    }
    
    return uniqueMap.values.toList();
  }
  
  /// 智能合并本地和服务器的会话列表
  /// 注意：服务器返回的lastMessage只包含接收的消息，不包含用户发送的消息
  /// 因此需要智能合并，保留最新的消息显示
  List<Conversation> _mergeConversations(
    List<Conversation> localList,
    List<Conversation> serverList,
  ) {
    Map<String, Conversation> mergedMap = {};
    
    // 先将服务器列表加入Map（服务器数据是接收消息的权威来源）
    for (var conversation in serverList) {
      if (conversation.chatId != null && conversation.chatId!.isNotEmpty) {
        mergedMap[conversation.chatId!] = conversation;
      }
    }
    
    // 再处理本地列表（本地可能包含用户刚发送的消息）
    for (var local in localList) {
      if (local.chatId == null || local.chatId!.isEmpty) {
        continue;
      }
      
      String chatId = local.chatId!;
      
      // 如果服务器也有该会话
      if (mergedMap.containsKey(chatId)) {
        var server = mergedMap[chatId]!;
        
        // 比较本地和服务器的最后消息时间
        if (local.lastMsgTime != null && server.lastMsgTime != null) {
          // ✅ 关键逻辑：本地的消息比服务器新，说明是用户刚发送的消息
          // 服务器只返回接收的消息，所以本地更新时应该保留本地数据
          if (local.lastMsgTime! > server.lastMsgTime!) {
            mergedMap[chatId] = local;
            info('💾 保留本地会话（用户刚发送）: $chatId, 本地时间=${local.lastMsgTime}, 服务器时间=${server.lastMsgTime}');
          } else if (local.lastMsgTime! < server.lastMsgTime!) {
            // 服务器有更新的接收消息，使用服务器数据
            mergedMap[chatId] = server;
            info('📥 使用服务器会话（有新接收消息）: $chatId, 服务器时间=${server.lastMsgTime}, 本地时间=${local.lastMsgTime}');
          } else {
            // 时间戳相同，优先使用服务器数据（服务器是权威数据源）
            mergedMap[chatId] = server;
            info('📥 时间戳相同，使用服务器会话: $chatId');
          }
        } else {
          // 如果没有时间戳，默认使用服务器的
          mergedMap[chatId] = server;
        }
      } else {
        // 服务器没有该会话，但本地有（可能是刚发起的新会话）
        mergedMap[chatId] = local;
        info('💾 保留本地新会话: $chatId');
      }
    }
    
    // 按最后消息时间倒序排序
    var result = mergedMap.values.toList();
    result.sort((a, b) {
      if (a.lastMsgTime == null && b.lastMsgTime == null) return 0;
      if (a.lastMsgTime == null) return 1;
      if (b.lastMsgTime == null) return -1;
      return b.lastMsgTime!.compareTo(a.lastMsgTime!);
    });
    
    return result;
  }
  
  /// 刷新会话列表
  Future<void> refreshConversations() async {
    await loadConversations();
  }

  void onConversationsUpdate(List<Conversation> data) {
    conversationList.assignAll(data);
  }

  void onConversationUpdate(Conversation data) {
    // ✅ 修复重复会话问题：只使用 chatId 匹配
    if (data.chatId == null || data.chatId!.isEmpty) {
      waring('⚠️ 会话更新缺少 chatId，忽略更新');
      return;
    }
    
    int index = conversationList.indexWhere(
      (element) => element.chatId == data.chatId,
    );
    
    if (index != -1) {
      // ✅ 更新现有会话，累加未读数（而不是替换）
      Conversation existingConversation = conversationList[index];
      conversationList[index] = data.copyWith(
        unreadCount: existingConversation.unreadCount + data.unreadCount,
      );
      conversationList.refresh();
      info('✅ 更新会话: ${data.targetUserName ?? data.targetUserId} (chatId: ${data.chatId}), 未读数: ${existingConversation.unreadCount} + ${data.unreadCount} = ${conversationList[index].unreadCount}');
    } else {
      // 添加新会话
      conversationList.add(data);
      info('➕ 添加新会话: ${data.targetUserName ?? data.targetUserId} (chatId: ${data.chatId})');
    }
  }
  
  /// 清零指定会话的未读数（进入聊天框时调用）
  void clearUnreadCount(String chatId) {
    if (chatId.isEmpty) return;
    
    int index = conversationList.indexWhere(
      (element) => element.chatId == chatId,
    );
    
    if (index != -1) {
      conversationList[index] = conversationList[index].copyWith(
        unreadCount: 0,
      );
      conversationList.refresh();
      info('🔄 清零会话未读数: $chatId');
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
