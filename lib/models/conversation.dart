// 会话模型
class Conversation {
  final String name;
  final String headImage;
  final String lastMessage;
  final String timestamp;
  final String userId;
  final int unreadCount;
  final String? targetUserId;        // 对方用户ID
  final String? targetUserName;      // 对方用户名
  final String? targetUserAvatar;    // 对方头像
  final int? lastMsgFormat;          // 最后消息格式 (0:文本, 1:图片, 2:语音等)
  final String? lastMsgId;           // 最后消息ID
  final int? lastMsgTime;            // 最后消息时间戳

  Conversation({
    required this.name,
    required this.headImage,
    required this.lastMessage,
    required this.timestamp,
    required this.userId,
    this.unreadCount = 0,
    this.targetUserId,
    this.targetUserName,
    this.targetUserAvatar,
    this.lastMsgFormat,
    this.lastMsgId,
    this.lastMsgTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      name: json['name'] ?? '',
      headImage: json['headImage'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      timestamp: json['timestamp'] ?? '',
      userId: json['userId'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      targetUserId: json['targetUserId'],
      targetUserName: json['targetUserName'],
      targetUserAvatar: json['targetUserAvatar'],
      lastMsgFormat: json['lastMsgFormat'],
      lastMsgId: json['lastMsgId'],
      lastMsgTime: json['lastMsgTime'],
    );
  }
}
