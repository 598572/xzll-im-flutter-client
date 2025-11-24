/// 用户信息模型
class UserInfo {
  final String userId;
  final String userName;
  final String? userFullName;
  final String? phone;
  final String? email;
  final String? headImage;
  final int? sex; // 0女, 1男, -1未知, 2其他
  final String? registerTime;
  final String? lastLoginTime;
  
  const UserInfo({
    required this.userId,
    required this.userName,
    this.userFullName,
    this.phone,
    this.email,
    this.headImage,
    this.sex,
    this.registerTime,
    this.lastLoginTime,
  });
  
  /// 从数据库记录创建
  factory UserInfo.fromDb(Map<String, dynamic> db) {
    return UserInfo(
      userId: db['user_id'] as String,
      userName: db['user_name'] as String,
      userFullName: db['user_full_name'] as String?,
      headImage: db['head_image'] as String?,
      sex: db['sex'] as int?,
    );
  }
  
  /// 从API响应创建
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userFullName: json['userFullName']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      headImage: json['headImage']?.toString(),
      sex: json['sex'] as int?,
      registerTime: json['registerTime']?.toString(),
      lastLoginTime: json['lastLoginTime']?.toString(),
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userFullName': userFullName,
      'phone': phone,
      'email': email,
      'headImage': headImage,
      'sex': sex,
      'registerTime': registerTime,
      'lastLoginTime': lastLoginTime,
    };
  }
  
  /// 复制并修改部分字段
  UserInfo copyWith({
    String? userId,
    String? userName,
    String? userFullName,
    String? phone,
    String? email,
    String? headImage,
    int? sex,
    String? registerTime,
    String? lastLoginTime,
  }) {
    return UserInfo(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userFullName: userFullName ?? this.userFullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      headImage: headImage ?? this.headImage,
      sex: sex ?? this.sex,
      registerTime: registerTime ?? this.registerTime,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
    );
  }
  
  @override
  String toString() {
    return 'UserInfo(userId: $userId, userName: $userName, userFullName: $userFullName)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserInfo && other.userId == userId;
  }
  
  @override
  int get hashCode => userId.hashCode;
}

/// 会话项模型
class ChatItem {
  final String chatId;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar; 
  final String? otherUserFullName;
  final String lastMessageContent;
  final int unreadCount;
  final int lastMsgTime;
  
  const ChatItem({
    required this.chatId,
    this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
    this.otherUserFullName,
    required this.lastMessageContent,
    required this.unreadCount,
    required this.lastMsgTime,
  });
  
  /// 从API响应创建
  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      chatId: json['chatId'] as String,
      otherUserId: json['otherUserId'] as String?,
      otherUserName: json['otherUserName'] as String?,
      otherUserAvatar: json['otherUserAvatar'] as String?,
      otherUserFullName: json['otherUserFullName'] as String?,
      lastMessageContent: json['lastMessageContent'] as String? ?? '',
      unreadCount: json['unReadCount'] as int? ?? 0,
      lastMsgTime: json['lastMsgTime'] as int? ?? 0,
    );
  }
  
  /// 复制并修改部分字段
  ChatItem copyWith({
    String? chatId,
    String? otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
    String? otherUserFullName,
    String? lastMessageContent,
    int? unreadCount,
    int? lastMsgTime,
  }) {
    return ChatItem(
      chatId: chatId ?? this.chatId,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      otherUserFullName: otherUserFullName ?? this.otherUserFullName,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMsgTime: lastMsgTime ?? this.lastMsgTime,
    );
  }
}
