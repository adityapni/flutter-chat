import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHistory{

  ChatHistory({
    required this.message,
    required this.sender,
    required this.groupname,
    required this.time
  });

  String message;
  String sender;
  String groupname;
  Timestamp time;
}