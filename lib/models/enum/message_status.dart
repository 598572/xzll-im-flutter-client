import 'package:json_annotation/json_annotation.dart';

/// 消息状态枚举
@JsonEnum(valueField: "code")
enum MessageStatus {
  fail(-1, "发送失败"),
  serverReceived(1, "已送达"),
  offLine(2, "离线"),
  unRead(3, "未读"),
  readed(4, "已读"),
  withdraw(5, "已撤回");

  const MessageStatus(this.code, this.desc);

  final int code;
  final String desc;

  // 根据code查找对应的状态
  static MessageStatus fromCode(int code) {
    return MessageStatus.values.firstWhere((status) => status.code == code, orElse: () => fail);
  }
}
