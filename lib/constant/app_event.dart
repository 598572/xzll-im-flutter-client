import 'package:rxdart/rxdart.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/domain/friend_request_push_message.dart';
import 'package:xzll_im_flutter_client/models/domain/message_status_changed_model.dart';
import 'package:xzll_im_flutter_client/models/enum/connectivity_status.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';

///事件通知总线
sealed class AppEvent {
  ///网络连接状态
  static PublishSubject<ConnectivityStatus> networkStatus = PublishSubject<ConnectivityStatus>();

  ///WebSocket连接状态
  static PublishSubject<WebSocketStatus> webSocketStatus = PublishSubject<WebSocketStatus>();

  ///消息状态变化事件
  ///[MessageStatusChangedModel] 消息状态变化时的数据模型
  ///通过订阅[onMessageStatusChanged]来监听消息状态变化事件
  static PublishSubject<MessageStatusChangedModel> onMessageStatusChanged =
      PublishSubject<MessageStatusChangedModel>();

  ///收到新消息事件
  ///[ChatMessage] 收到的新消息
  ///通过订阅[onMessageReceived]来监听收到新消息事件
  static PublishSubject<ChatMessage> onMessageReceived = PublishSubject<ChatMessage>();

  ///会话列表更新事件
  ///[List<Conversation>] 更新后的会话列表
  ///通过订阅[onConversationsUpdated]来监听会话列表更新事件
  static PublishSubject<List<Conversation>> onConversationsUpdated =
      PublishSubject<List<Conversation>>();

  ///单个会话更新事件
  ///[Conversation] 更新后的会话
  ///通过订阅[onConversationUpdated]来监听单个会话更新事件
  static PublishSubject<Conversation> onConversationUpdated = PublishSubject<Conversation>();

  /// 好友申请推送回调
  static PublishSubject<FriendRequestPushMessage> onFriendRequestPush =
      PublishSubject<FriendRequestPushMessage>();
}
