import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: "code")
enum MessageType {
  unknown(0, "未知消息"),
  text(1, "[文本]"),        // TEXT_MSG
  voice(2, "[语音]"),       // VOICE_MSG
  location(3, "[位置]");    // LOCATION_MSG

  final int code;
  final String desc;

  const MessageType(this.code, this.desc);

  static MessageType fromCode(int code) {
    return MessageType.values.firstWhere((e) => e.code == code, orElse: () => MessageType.unknown);
  }
}
