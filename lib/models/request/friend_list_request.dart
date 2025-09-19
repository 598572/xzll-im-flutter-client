// 好友列表查询请求模型
class FriendListRequest {
  final String userId;
  final int currentPage;
  final int pageSize;

  FriendListRequest({required this.userId, this.currentPage = 1, this.pageSize = 20});

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'currentPage': currentPage, 'pageSize': pageSize};
  }
}
