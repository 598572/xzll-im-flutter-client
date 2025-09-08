// 消息类型枚举 - 与Java MsgFormatEnum保持一致
enum MessageType {
  textMsg(1, "文本消息"),
  voiceMsg(2, "语音条消息"),
  locationMsg(3, "地理位置消息");

  const MessageType(this.code, this.desc);
  
  final int code;
  final String desc;

  // 根据code查找对应的类型
  static MessageType? fromCode(int code) {
    for (MessageType type in MessageType.values) {
      if (type.code == code) {
        return type;
      }
    }
    return null;
  }

  // 根据code查找对应的描述
  static String? getDescByCode(int code) {
    for (MessageType type in MessageType.values) {
      if (type.code == code) {
        return type.desc;
      }
    }
    return null;
  }
}

// 消息状态枚举 - 与Java MsgStatus保持一致
enum MessageStatus {
  fail(-1, "发送失败"),
  serverReceived(1, "消息已送达服务器"),
  offLine(2, "离线"),
  unRead(3, "未读"),
  readed(4, "已读");

  const MessageStatus(this.code, this.desc);
  
  final int code;
  final String desc;

  // 根据code查找对应的状态
  static MessageStatus? fromCode(int code) {
    for (MessageStatus status in MessageStatus.values) {
      if (status.code == code) {
        return status;
      }
    }
    return null;
  }

  // 根据code查找对应的描述
  static String? getDescByCode(int code) {
    for (MessageStatus status in MessageStatus.values) {
      if (status.code == code) {
        return status.desc;
      }
    }
    return null;
  }
}

// 消息撤回状态枚举 - 与Java MsgWithdrawStatus保持一致
enum MessageWithdrawStatus {
  no(0, "未撤回"),
  yes(1, "已撤回");

  const MessageWithdrawStatus(this.code, this.desc);
  
  final int code;
  final String desc;

  // 根据code查找对应的状态
  static MessageWithdrawStatus? fromCode(int code) {
    for (MessageWithdrawStatus status in MessageWithdrawStatus.values) {
      if (status.code == code) {
        return status;
      }
    }
    return null;
  }
}

// 消息模型
class ChatMessage {
  final String msgId;
  final String content;
  final String fromUserId;
  final String toUserId;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final MessageWithdrawStatus withdrawStatus;

  ChatMessage({
    required this.msgId,
    required this.content,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    this.status = MessageStatus.serverReceived,
    required this.timestamp,
    this.withdrawStatus = MessageWithdrawStatus.no,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      msgId: json['msgId'] ?? '',
      content: json['msgContent'] ?? '',
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      type: MessageType.fromCode(json['msgFormat'] ?? 1) ?? MessageType.textMsg,
      status: MessageStatus.fromCode(json['msgStatus'] ?? 1) ?? MessageStatus.serverReceived,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        json['msgCreateTime'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      withdrawStatus: MessageWithdrawStatus.fromCode(json['withdrawStatus'] ?? 0) ?? MessageWithdrawStatus.no,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msgId': msgId,
      'msgContent': content,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'msgFormat': type.code,
      'msgStatus': status.code,
      'msgCreateTime': timestamp.millisecondsSinceEpoch,
      'withdrawStatus': withdrawStatus.code,
    };
  }
}
