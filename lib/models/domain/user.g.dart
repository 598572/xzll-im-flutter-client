// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  userName: json['userName'] as String,
  phone: json['phone'] as String?,
  sex: (json['sex'] as num?)?.toInt(),
  avatar: json['avatar'] as String?,
  createTime: _$JsonConverterFromJson<int, DateTime>(
    json['createTime'],
    const EpochDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'userName': instance.userName,
  'phone': instance.phone,
  'sex': instance.sex,
  'avatar': instance.avatar,
  'createTime': _$JsonConverterToJson<int, DateTime>(
    instance.createTime,
    const EpochDateTimeConverter().toJson,
  ),
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
