import 'package:json_annotation/json_annotation.dart';
part 'app_user.g.dart';

@JsonSerializable()
class AppUser{
  AppUser({
    this.username = '',
    this.callingWho,
    this.calledBy,
  });

  final String username;
  final String? callingWho;
  final String? calledBy;

  factory AppUser.fromJson(Map<String,dynamic> json ) => _$AppUserFromJson(json);
  Map<String,dynamic> toJson() => _$AppUserToJson(this);
}