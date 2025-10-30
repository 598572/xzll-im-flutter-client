import 'package:json_annotation/json_annotation.dart';

/// 消息状态枚举 (与服务端保持一致)
@JsonEnum(valueField: "code")
enum MessageStatus {
  fail(-1, "发送失败"),         // 客户端展示：重试按钮
  sending(0, "发送中"),         // 客户端展示：转圈loading
  serverReceived(1, "未读"),    // 服务器确认后显示为未读
  offLine(2, "未读"),          // 对方离线时显示为未读
  unRead(3, "未读"),           // 对方未读时显示为未读
  readed(4, "已读"),           // 对方已读时显示为已读
  withdraw(5, "已撤回");

  const MessageStatus(this.code, this.desc);

  final int code;
  final String desc;

  // 根据code查找对应的状态
  static MessageStatus fromCode(int code) {
    return MessageStatus.values.firstWhere((status) => status.code == code, orElse: () => fail);
  }
}
