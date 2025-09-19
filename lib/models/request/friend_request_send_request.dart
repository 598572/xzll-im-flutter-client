// 好友申请发送请求模型
class FriendRequestSendRequest {
  final String fromUserId;
  final String toUserId;
  final String? requestMessage;

  FriendRequestSendRequest({required this.fromUserId, required this.toUserId, this.requestMessage});

  Map<String, dynamic> toJson() {
    return {'fromUserId': fromUserId, 'toUserId': toUserId, 'requestMessage': requestMessage ?? ''};
  }
}
