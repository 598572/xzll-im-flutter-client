import 'package:xzll_im_flutter_client/models/enum/message_status.dart';

///消息状态变化时的数据模型
///
/// 双轨制支持：
/// - messageId: 可以是 clientMsgId 或 serverMsgId（用于查找消息）
/// - serverMsgId: 可选，收到 SERVER_ACK 时会携带此字段（用于更新消息的 serverMsgId）
class MessageStatusChangedModel {
  final String messageId;
  final MessageStatus messageStatus;
  final String? serverMsgId; // ✅ 新增：用于更新消息的 serverMsgId

  MessageStatusChangedModel({
    required this.messageId,
    required this.messageStatus,
    this.serverMsgId, // 可选字段
  });
}
