// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  token: json['token'] as String,
  refreshToken: json['refreshToken'] as String,
  tokenHead: json['tokenHead'] as String,
  expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'tokenHead': instance.tokenHead,
      'expiresIn': instance.expiresIn,
    };
