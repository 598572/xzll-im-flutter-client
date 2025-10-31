import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/domain/friend.dart';
import 'package:xzll_im_flutter_client/router/router_name.dart';
import 'package:xzll_im_flutter_client/screens/contacts/contacts_logic.dart';

class ContactsView extends GetView<ContactsLogic> {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("通讯录"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Get.toNamed(RouterName.userSearch);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.friendList.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty && controller.friendList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshFriendList,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        if (controller.friendList.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshFriendList,
            child: CustomScrollView(
              slivers: [
                // 功能入口区域（即使没有好友也要显示）
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // 新的朋友入口
                        _buildNewFriendsEntry(),
                        const Divider(height: 1, indent: 60),
                        // 群聊入口（预留）
                        _buildGroupChatEntry(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                
                // 空状态提示
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无好友',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '点击上方"新的朋友"查看好友申请',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.toNamed(RouterName.userSearch);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.person_add),
                          label: const Text('搜索添加好友'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshFriendList,
          child: _buildFriendList(),
        );
      }),
    );
  }

  Widget _buildFriendList() {
    final groupedFriends = controller.groupedFriends;
    
    return CustomScrollView(
      slivers: [
        // 功能入口区域
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // 新的朋友入口
                _buildNewFriendsEntry(),
                const Divider(height: 1, indent: 60),
                // 群聊入口（预留）
                _buildGroupChatEntry(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        
        // 好友统计
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.people, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${controller.friendList.length} 位好友',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 好友列表（按首字母分组）
        ...groupedFriends.entries.map((entry) {
          final letter = entry.key;
          final friends = entry.value;
          
          return SliverList(
            delegate: SliverChildListDelegate([
              // 分组标题
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: Text(
                  letter,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              // 该分组下的好友列表
              ...friends.map((friend) => _buildFriendItem(friend)),
            ]),
          );
        }),
      ],
    );
  }

  Widget _buildFriendItem(Friend friend) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.blue[100],
        backgroundImage: friend.friendAvatar != null && friend.friendAvatar!.isNotEmpty
            ? NetworkImage(friend.friendAvatar!)
            : null,
        child: friend.friendAvatar == null || friend.friendAvatar!.isEmpty
            ? Text(
                friend.displayName.isNotEmpty ? friend.displayName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        friend.displayName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: friend.blackFlag == true
          ? const Text(
              '已拉黑',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            )
          : Text(
              friend.sexText,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
      trailing: friend.blackFlag == true
          ? const Icon(Icons.block, color: Colors.red, size: 20)
          : null,
      onTap: () {
        _showFriendOptions(friend);
      },
    );
  }

  void _showFriendOptions(Friend friend) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 好友信息
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  backgroundImage: friend.friendAvatar != null && friend.friendAvatar!.isNotEmpty
                      ? NetworkImage(friend.friendAvatar!)
                      : null,
                  child: friend.friendAvatar == null || friend.friendAvatar!.isEmpty
                      ? Text(
                          friend.displayName.isNotEmpty ? friend.displayName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${friend.sexText} • 好友ID: ${friend.friendId}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 操作按钮
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child:                   ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _startChatWithFriend(friend);
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('发消息'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      // TODO: 查看好友资料
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('查看资料'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (friend.blackFlag == true) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        // TODO: 取消拉黑
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('取消拉黑'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        // TODO: 拉黑好友
                      },
                      icon: const Icon(Icons.block),
                      label: const Text('拉黑'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _confirmDeleteFriend(friend);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('删除好友'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteFriend(Friend friend) {
    Get.dialog(
      AlertDialog(
        title: const Text('删除好友'),
        content: Text('确定要删除好友 ${friend.displayName} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: 实现删除好友功能
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 开始与好友聊天
  void _startChatWithFriend(Friend friend) {
    // 创建会话对象（从联系人启动聊天时没有服务端chatId，需要客户端生成）
    final conversation = Conversation(
      name: friend.displayName,
      headImage: friend.friendAvatar ?? 'assets/other_headImage.png',
      lastMessage: '',
      timestamp: DateTime.now().toString(),
      userId: controller.appData.user.value.id,
      unreadCount: 0,
      targetUserId: friend.friendId,
      targetUserName: friend.displayName, // 使用 displayName 而不是 friendName
      targetUserAvatar: friend.friendAvatar,
      chatId: null, // 从联系人启动聊天时没有chatId，由ChatLogic生成
    );

    // 跳转到聊天页面
    Get.toNamed(
      RouterName.chat,
      arguments: conversation,
    );
  }

  /// 构建新的朋友入口
  Widget _buildNewFriendsEntry() {
    return Obx(() => ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.person_add,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: const Text(
        '新的朋友',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.unreadFriendRequestCount.value > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 20),
              child: Text(
                controller.unreadFriendRequestCount.value > 99 
                    ? '99+' 
                    : '${controller.unreadFriendRequestCount.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: () {
        Get.toNamed(RouterName.friendRequest);
      },
    ));
  }

  /// 构建群聊入口
  Widget _buildGroupChatEntry() {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.group,
          color: Colors.white,
          size: 24,
        ),
      ),
      title: const Text(
        '群聊',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        Get.snackbar('提示', '群聊功能开发中...');
      },
    );
  }
}
