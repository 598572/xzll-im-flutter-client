import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum MessageType {
  unknown(0, "未知消息"),
  text(1, "文本消息"),
  voice(2, "语音消息"),
  location(3, "位置消息");

  final int code;
  final String desc;

  const MessageType(this.code, this.desc);

  static MessageType fromCode(int code) {
    return MessageType.values.firstWhere((e) => e.code == code, orElse: () => MessageType.unknown);
  }
}
