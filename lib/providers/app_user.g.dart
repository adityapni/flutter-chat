// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return AppUser(
    username: json['username'] as String,
    callingWho: json['callingWho'] as String?,
    calledBy: json['calledBy'] as String?,
  );
}

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
      'username': instance.username,
      'callingWho': instance.callingWho,
      'calledBy': instance.calledBy,
    };
