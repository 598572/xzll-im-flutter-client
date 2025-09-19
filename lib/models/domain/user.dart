import 'package:json_annotation/json_annotation.dart';
import 'package:xzll_im_flutter_client/models/domain/epoch_date_time_converter.dart';

part "user.g.dart";

// 用户信息模型
@JsonSerializable()
class User {
  final String id;
  final String userName;
  final String? phone;
  final int? sex; // 1-男, 2-女
  final String? avatar;
  @EpochDateTimeConverter()
  final DateTime? createTime;

  User({
    required this.id,
    required this.userName,
    this.phone,
    this.sex,
    this.avatar,
    this.createTime,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
