// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSearchResult _$UserSearchResultFromJson(Map<String, dynamic> json) =>
    UserSearchResult(
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userFullName: json['userFullName'] as String?,
      headImage: json['headImage'] as String?,
      sex: (json['sex'] as num?)?.toInt(),
      phoneHidden: json['phoneHidden'] as String?,
      emailHidden: json['emailHidden'] as String?,
      friendStatus: (json['friendStatus'] as num?)?.toInt() ?? 0,
      friendStatusText: json['friendStatusText'] as String?,
      registerTime: json['registerTime'] == null
          ? null
          : DateTime.parse(json['registerTime'] as String),
      canSendRequest: json['canSendRequest'] as bool? ?? false,
      pendingRequestId: json['pendingRequestId'] as String?,
    );

Map<String, dynamic> _$UserSearchResultToJson(UserSearchResult instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'userFullName': instance.userFullName,
      'headImage': instance.headImage,
      'sex': instance.sex,
      'phoneHidden': instance.phoneHidden,
      'emailHidden': instance.emailHidden,
      'friendStatus': instance.friendStatus,
      'friendStatusText': instance.friendStatusText,
      'registerTime': instance.registerTime?.toIso8601String(),
      'canSendRequest': instance.canSendRequest,
      'pendingRequestId': instance.pendingRequestId,
    };
