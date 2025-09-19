// 好友申请列表查询请求模型
class FriendRequestListRequest {
  final String userId;
  final int requestType; // 1-我发出的申请，2-我收到的申请
  final int currentPage;
  final int pageSize;

  FriendRequestListRequest({
    required this.userId,
    this.requestType = 2,
    this.currentPage = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'requestType': requestType,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }
}