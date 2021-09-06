// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) {
  return ChatModel(
    message: json['message'] as String?,
    user: json['user'] as String?,
    time: const CustomDateTimeConverter().fromJson(json['time'].toString()),
  );
}

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
      'time': const CustomDateTimeConverter().toJson(instance.time),
    };
