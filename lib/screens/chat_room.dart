import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/providers/chat_model.dart';
import 'package:my_chat/providers/firebase_chat.dart';
import 'package:my_chat/views/chat_tile.dart';
import 'package:provider/provider.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();

  ChatRoom({
    this.friend
});
  final String? friend;

}

class _ChatRoomState extends State<ChatRoom> {

  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FirebaseChat>(
      create: (BuildContext context) =>FirebaseChat.toOne(user: '${FirebaseAuth.instance.currentUser!.phoneNumber}'
          , friend: '${widget.friend}'),
      child: ChatScreen(controller: controller,friend: widget.friend,),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.controller,
    this.friend
  }) : super(key: key);

  final TextEditingController controller;
  final String? friend;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {



  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var firebaseChat = context.watch<FirebaseChat>();
    var chatRoomId = firebaseChat.chatRoomId;
    if (chatRoomId != null){
      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                color: Colors.blue[100],
                height: height,
                width: width,
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                child: FutureBuilder(
                  future: context.watch<FirebaseChat>().getChat(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<ChatModel>> snapshot) {
                    // print('initial data ${snapshot.hasData} ');
                    // print('connection state ${snapshot.connectionState}');
                    if (snapshot.hasError){
                      return Text('error');
                    }
                    else if (snapshot.hasData){
                      // print('data ${snapshot.data!.docs}');
                      // return Text('has data');
                    }
                    if (!snapshot.hasData){
                      //do nothing
                    }
                    if (snapshot.connectionState == ConnectionState.done && snapshot.data!.docs.isEmpty){
                      //no message yet
                      return Container();
                    }
                    if (snapshot.connectionState == ConnectionState.done && snapshot.data!.docs.isNotEmpty){
                      return ListView(
                        children: snapshot.data!.docs.map((e)
                        {
                          // print('data ${e.data().user}');
                          var date = e.data().time!.toDate();
                          var hour = date.hour;
                          var min = date.minute;
                          return Align(child:
                          ChatTile(username: e.data().user, message: e.data().message, time: '$hour:$min'),
                          alignment: e.data().user==FirebaseAuth.instance.currentUser!.phoneNumber ?
                              Alignment.centerRight:Alignment.centerLeft,);
                        }
                        ).toList(),
                      );
                    }
                    return Center(child: SizedBox(width:30,height:30,child: CircularProgressIndicator()));
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                child: SizedBox(
                  width: width,
                  child: Row(
                    children: [
                      SizedBox(width: 5,),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                            color: Colors.white,),
                          // width: width*0.7,
                          child: TextField(
                            decoration: InputDecoration(border: InputBorder.none,
                            hintText: 'Type a message'),
                            controller: widget.controller,
                          ),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 50,minHeight: 50) ,
                        child: ElevatedButton(
                          onPressed: (){
                            String message = widget.controller.text;
                            firebaseChat.send(message: message, user: FirebaseAuth.instance.currentUser!.phoneNumber!);
                            widget.controller.text = '';
                            FocusScope.of(context).unfocus();
                          },
                          child: Icon(Icons.send),
                          style: ElevatedButton.styleFrom(shape: CircleBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );


  }
}
