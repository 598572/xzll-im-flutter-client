import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: "code")
enum MessageType {
  unknown(6, "未知消息"),
  text(0, "[文本]"),
  image(1, "[图片]"),
  voice(2, "[语音]"),
  video(3, "[视频]"),
  file(4, "[文件]"),
  location(5, "[位置]");

  final int code;
  final String desc;

  const MessageType(this.code, this.desc);

  static MessageType fromCode(int code) {
    return MessageType.values.firstWhere((e) => e.code == code, orElse: () => MessageType.unknown);
  }
}
