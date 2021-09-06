import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/providers/chat_history.dart';
import 'package:my_chat/providers/chat_model.dart';



class FirebaseChat with ChangeNotifier{

  FirebaseChat.showHistory({this.user='',this.friend=''});

  FirebaseChat.toOne({required this.user, required this.friend}){
    init(user: user, friend: friend);
  }


  init({required String user, required String friend}) async {
    print('init sender $user');
    print('init friend $friend');
    chatRoomId = await FirebaseFirestore.instance.collection('chats').where('room',isEqualTo: 'group $user $friend')
        .get().then((value) {
          if(value.docs.isNotEmpty){
            //existing chat
            return value.docs.first.id;
          }
          else {
            //make new chat
            return FirebaseFirestore.instance.collection('chats').add({'room':'group $user $friend'})
                .then((value) => value.id);
          }
        });

    chatRev = FirebaseFirestore.instance.collection('chats')
        .doc(chatRoomId).collection('someCollectionId')
        .withConverter(fromFirestore: (snapshot,_) => ChatModel.fromJson(snapshot.data()!)
        , toFirestore: (ChatModel chatModel,_) => chatModel.toJson());

    notifyListeners();

  }

  var chatRoomId;
  CollectionReference<ChatModel>? chatRev;
  String user;
  String friend;
  List<ChatHistory> historyList =[];

  Future<QuerySnapshot<ChatModel>> getChat()  async {
    var querySnap =  await chatRev!.orderBy('time').get();
    return querySnap;
  }

  send({required String message, required String user}){
    //send message
    chatRev!.add(ChatModel(message: message,user: user,time: Timestamp.now()));
    //save chat history
    FirebaseFirestore.instance.collection('chat history').doc(FirebaseAuth.instance.currentUser!.phoneNumber)
    .collection('messages').doc('$chatRoomId').set({'time':Timestamp.now(),'room id':chatRoomId},SetOptions(merge: true));

    //save chat history to receiver
    FirebaseFirestore.instance.collection('chat history').doc(friend)
        .collection('messages').doc('$chatRoomId').set({'time':Timestamp.now(),'room id':chatRoomId},SetOptions(merge: true));
  }

  Stream<List<ChatHistory>> getHistory() async* {
    QuerySnapshot<Map<String,dynamic>> history =  await FirebaseFirestore.instance.collection('chat history')
        .doc(FirebaseAuth.instance.currentUser!.phoneNumber)
        .collection('messages').orderBy('time').get();
    print('history length ${history.docs.length} ,user ${FirebaseAuth.instance.currentUser!.phoneNumber}');

   await Future.forEach(history.docs,(QueryDocumentSnapshot<Map<String,dynamic>> element) async {
      var roomId = element.data()['room id'];
      var time = element.data()['time'];
      print('room id $roomId time $time');

      var rev = FirebaseFirestore.instance.collection('chats').doc(roomId).collection('someCollectionId')
          .withConverter(fromFirestore: (snapshot,_) => ChatModel.fromJson(snapshot.data()!)
          , toFirestore: (ChatModel chatModel,_) => chatModel.toJson());
      String? lastPost;
      String? sender;
      await rev.orderBy('time').get().then((value) {
        lastPost = value.docs.last.data().message;
        sender = value.docs.last.data().user;
      });
       print('lastPost $lastPost sender $sender');

      String roomName = await FirebaseFirestore.instance.collection('chats').doc(roomId).get()
      .then((value) => value.data()!['room']);
      print('roomname $roomName');

      historyList.add(ChatHistory(message: '$lastPost', sender: '$sender', groupname: roomName, time: time));

    });

    if(historyList.length != 0 && historyList.length == history.docs.length){
      notifyListeners();
    }

    yield historyList;
  }



}