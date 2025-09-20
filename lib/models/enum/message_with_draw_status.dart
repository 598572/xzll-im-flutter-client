// 消息撤回状态枚举

import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: "code")
enum MessageWithdrawStatus {
  no(0, "未撤回"),
  yes(1, "已撤回");

  const MessageWithdrawStatus(this.code, this.desc);

  final int code;
  final String desc;

  // 根据code查找对应的状态
  static MessageWithdrawStatus fromCode(int code) {
    return MessageWithdrawStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => no,
    );
  }
}
