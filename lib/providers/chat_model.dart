import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_chat/utils/custom_datetime.dart';
part 'chat_model.g.dart';

@JsonSerializable()
@CustomDateTimeConverter()
class ChatModel{
  ChatModel({
    this.message,
    this.user,
    this.time
});
  String? message;
  String? user;
  Timestamp? time;

  factory ChatModel.fromJson(Map<String,dynamic> json ) => _$ChatModelFromJson(json);
  Map<String,dynamic> toJson() => _$ChatModelToJson(this);
}