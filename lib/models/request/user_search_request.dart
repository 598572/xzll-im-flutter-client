// 用户搜索请求模型
class UserSearchRequest {
  final String keyword;
  final int searchType; // 1-精确搜索，2-模糊搜索
  final String currentUserId;
  final int currentPage;
  final int pageSize;

  UserSearchRequest({
    required this.keyword,
    this.searchType = 2,
    required this.currentUserId,
    this.currentPage = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'searchType': searchType,
      'currentUserId': currentUserId,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }
}
