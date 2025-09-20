// 定义 WebSocket 消息处理类型枚举，集中管理所有后端返回的 url 标识，便于维护与替换
enum HandleType {
  // 单聊发送结果（客户端发送 -> 服务器回执）
  c2cSend('xzll/im/c2c/send'),
  // 单聊收到新消息（服务器推送给接收方）
  c2cReceive('xzll/im/c2c/receive'),
  // 批量获取消息ID
  c2cGetBatchMsgId('xzll/im/c2c/get/batch/msgId'),
  // 服务器已收到消息（发送方收到）
  c2cAckServerReceived('xzll/im/c2c/response/ack/server/received'),
  // 接收方未读确认（发送方收到）
  c2cAckToUserUnread('xzll/im/c2c/response/ack/toUser/unread'),
  // 接收方已读确认（发送方收到）
  c2cAckToUserRead('xzll/im/c2c/response/ack/toUser/read'),
  // 撤回消息
  c2cWithdraw('xzll/im/c2c/withdraw'),
  // 会话列表
  conversationList('xzll/im/conversation/list'),
  // 会话更新
  conversationUpdate('xzll/im/conversation/update'),
  // 好友申请推送
  friendRequestPush('xzll/im/friend/request/push'),
  // 好友申请处理结果推送
  friendRequestHandlePush('xzll/im/friend/request/handle/push');

  final String url;
  const HandleType(this.url);

  // 通过后端返回的 url 匹配枚举，未匹配返回 null
  static HandleType? fromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    for (final type in HandleType.values) {
      if (type.url == url) return type;
    }
    return null;
  }
}
