// 好友申请处理请求模型
class FriendRequestHandleRequest {
  final String requestId;
  final String userId;
  final int handleResult; // 1-同意，2-拒绝

  FriendRequestHandleRequest({
    required this.requestId,
    required this.userId,
    required this.handleResult,
  });

  Map<String, dynamic> toJson() {
    return {'requestId': requestId, 'userId': userId, 'handleResult': handleResult};
  }
}
