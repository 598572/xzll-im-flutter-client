// 好友相关数据模型

// 好友信息模型
class Friend {
  final String friendId;
  final String? friendUserName;
  final String? friendFullName;
  final String? friendHeadImage;
  final int? friendSex; // 0-女，1-男，-1-未知
  final bool? blackFlag;
  final DateTime? createTime;

  Friend({
    required this.friendId,
    this.friendUserName,
    this.friendFullName,
    this.friendHeadImage,
    this.friendSex,
    this.blackFlag,
    this.createTime,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      friendId: json['friendId']?.toString() ?? '',
      friendUserName: json['friendUserName'],
      friendFullName: json['friendFullName'],
      friendHeadImage: json['friendHeadImage'],
      friendSex: json['friendSex'],
      blackFlag: json['blackFlag'],
      createTime: json['createTime'] != null 
          ? DateTime.parse(json['createTime']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'friendId': friendId,
      'friendUserName': friendUserName,
      'friendFullName': friendFullName,
      'friendHeadImage': friendHeadImage,
      'friendSex': friendSex,
      'blackFlag': blackFlag,
      'createTime': createTime?.toIso8601String(),
    };
  }

  String get displayName => friendFullName ?? friendUserName ?? friendId;
  String get sexText {
    switch (friendSex) {
      case 0:
        return '女';
      case 1:
        return '男';
      default:
        return '未知';
    }
  }
}

// 好友申请模型
class FriendRequest {
  final String requestId;
  final String fromUserId;
  final String? fromUserName;
  final String toUserId;
  final String? toUserName;
  final String? requestMessage;
  final int status; // 0-待处理，1-已同意，2-已拒绝，3-已过期
  final DateTime? handleTime;
  final DateTime createTime;

  FriendRequest({
    required this.requestId,
    required this.fromUserId,
    this.fromUserName,
    required this.toUserId,
    this.toUserName,
    this.requestMessage,
    required this.status,
    this.handleTime,
    required this.createTime,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      requestId: json['requestId']?.toString() ?? '',
      fromUserId: json['fromUserId']?.toString() ?? '',
      fromUserName: json['fromUserName'],
      toUserId: json['toUserId']?.toString() ?? '',
      toUserName: json['toUserName'],
      requestMessage: json['requestMessage'],
      status: json['status'] ?? 0,
      handleTime: json['handleTime'] != null 
          ? DateTime.parse(json['handleTime']) 
          : null,
      createTime: json['createTime'] != null 
          ? DateTime.parse(json['createTime']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'requestMessage': requestMessage,
      'status': status,
      'handleTime': handleTime?.toIso8601String(),
      'createTime': createTime.toIso8601String(),
    };
  }

  String get statusText {
    switch (status) {
      case 0:
        return '待处理';
      case 1:
        return '已同意';
      case 2:
        return '已拒绝';
      case 3:
        return '已过期';
      default:
        return '未知';
    }
  }

  bool get isPending => status == 0;
  bool get isAccepted => status == 1;
  bool get isRejected => status == 2;
  bool get isExpired => status == 3;
}

// 用户搜索结果模型
class UserSearchResult {
  final String userId;
  final String? userName;
  final String? userFullName;
  final String? headImage;
  final int? sex;
  final String? phoneHidden;
  final String? emailHidden;
  final int friendStatus; // 0-非好友，1-已是好友，2-已发送申请待处理，3-已被拉黑
  final String? friendStatusText;
  final DateTime? registerTime;
  final bool canSendRequest;
  final String? pendingRequestId;

  UserSearchResult({
    required this.userId,
    this.userName,
    this.userFullName,
    this.headImage,
    this.sex,
    this.phoneHidden,
    this.emailHidden,
    required this.friendStatus,
    this.friendStatusText,
    this.registerTime,
    required this.canSendRequest,
    this.pendingRequestId,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      userId: json['userId']?.toString() ?? '',
      userName: json['userName'],
      userFullName: json['userFullName'],
      headImage: json['headImage'],
      sex: json['sex'],
      phoneHidden: json['phoneHidden'],
      emailHidden: json['emailHidden'],
      friendStatus: json['friendStatus'] ?? 0,
      friendStatusText: json['friendStatusText'],
      registerTime: json['registerTime'] != null 
          ? DateTime.parse(json['registerTime']) 
          : null,
      canSendRequest: json['canSendRequest'] ?? false,
      pendingRequestId: json['pendingRequestId'],
    );
  }

  String get displayName => userFullName ?? userName ?? userId;
  String get sexText {
    switch (sex) {
      case 0:
        return '女';
      case 1:
        return '男';
      default:
        return '未知';
    }
  }

  bool get isFriend => friendStatus == 1;
  bool get hasPendingRequest => friendStatus == 2;
  bool get isBlocked => friendStatus == 3;
  bool get isStranger => friendStatus == 0;
}

// 好友申请发送请求模型
class FriendRequestSendRequest {
  final String fromUserId;
  final String toUserId;
  final String? requestMessage;

  FriendRequestSendRequest({
    required this.fromUserId,
    required this.toUserId,
    this.requestMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'requestMessage': requestMessage ?? '',
    };
  }
}

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
    return {
      'requestId': requestId,
      'userId': userId,
      'handleResult': handleResult,
    };
  }
}

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

// 好友列表查询请求模型
class FriendListRequest {
  final String userId;
  final int currentPage;
  final int pageSize;

  FriendListRequest({
    required this.userId,
    this.currentPage = 1,
    this.pageSize = 20,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentPage': currentPage,
      'pageSize': pageSize,
    };
  }
}

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

// 好友申请推送消息模型
class FriendRequestPushMessage {
  final int pushType; // 1-新的好友申请，2-好友申请处理结果
  final String requestId;
  final String fromUserId;
  final String? fromUserName;
  final String? fromUserAvatar;
  final String toUserId;
  final String? requestMessage;
  final int status;
  final String? statusText;
  final DateTime? handleTime;
  final DateTime createTime;
  final String? pushTitle;
  final String? pushContent;

  FriendRequestPushMessage({
    required this.pushType,
    required this.requestId,
    required this.fromUserId,
    this.fromUserName,
    this.fromUserAvatar,
    required this.toUserId,
    this.requestMessage,
    required this.status,
    this.statusText,
    this.handleTime,
    required this.createTime,
    this.pushTitle,
    this.pushContent,
  });

  factory FriendRequestPushMessage.fromJson(Map<String, dynamic> json) {
    return FriendRequestPushMessage(
      pushType: json['pushType'] ?? 1,
      requestId: json['requestId']?.toString() ?? '',
      fromUserId: json['fromUserId']?.toString() ?? '',
      fromUserName: json['fromUserName'],
      fromUserAvatar: json['fromUserAvatar'],
      toUserId: json['toUserId']?.toString() ?? '',
      requestMessage: json['requestMessage'],
      status: json['status'] ?? 0,
      statusText: json['statusText'],
      handleTime: json['handleTime'] != null 
          ? DateTime.parse(json['handleTime']) 
          : null,
      createTime: json['createTime'] != null 
          ? DateTime.parse(json['createTime']) 
          : DateTime.now(),
      pushTitle: json['pushTitle'],
      pushContent: json['pushContent'],
    );
  }

  bool get isNewRequest => pushType == 1;
  bool get isHandleResult => pushType == 2;
}
