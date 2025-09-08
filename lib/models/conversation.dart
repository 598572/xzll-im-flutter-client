// 会话模型
class Conversation {
  final String name;
  final String headImage;
  final String lastMessage;
  final String timestamp;
  final String userId;
  final int unreadCount;

  Conversation({
    required this.name,
    required this.headImage,
    required this.lastMessage,
    required this.timestamp,
    required this.userId,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      name: json['name'] ?? '',
      headImage: json['headImage'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      timestamp: json['timestamp'] ?? '',
      userId: json['userId'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
