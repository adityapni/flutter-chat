import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/providers/chat_history.dart';
import 'package:my_chat/providers/firebase_chat.dart';
import 'package:provider/provider.dart';

import 'contact.dart';

class Chat extends StatelessWidget {

  //placeholder
  // List<MessageTile> messageList = [MessageTile(username: 'Friend', message: 'Hi. Happy Birthday!', time: '08:00'),
  // MessageTile(username: 'Another Friend', message: 'You forgot your keys', time: '08:30'),
  // MessageTile(username: "Friend's Friend", message: 'Hi, can you join us on....', time: '09:00'),
  // MessageTile(username: 'Boss', message: 'Get back to work!', time: '09:30'),
  // MessageTile(username: 'GF', message: 'Hi Honey', time: '10:00'),
  // MessageTile(username: 'Landlord', message: 'Please pay your rent', time: '10:30'),
  // MessageTile(username: 'Mom', message: 'Check out this funny cat', time: '11:00'),
  // MessageTile(username: 'Gorilla', message: 'grr grr argh', time: '11:30')];


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FirebaseChat>(
      create: (BuildContext context) => FirebaseChat.showHistory(),
      child: Scaffold(
        body: HistoryList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Contacts(mode: 'chat',)));
          },
          child: Icon(Icons.chat),
        ),
      ),
    );
  }
}

class HistoryList extends StatefulWidget {
  const HistoryList({
    Key? key,
  }) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  var history;

  @override
  void initState() {
    history = context.read<FirebaseChat>().getHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: StreamBuilder(
        stream: history,
        builder: (BuildContext context, AsyncSnapshot<List<ChatHistory>> snapshot) {
          print('data ${snapshot.data}');
          if (snapshot.hasError){
            return Text(snapshot.error.toString());
          }
          if(snapshot.connectionState == ConnectionState.done && snapshot.data!.isNotEmpty){
            return ListView(
              children: snapshot.data!.map((e) => MessageTile(username: e.sender, message: e.message,
                  time: e.time.toDate().toString())).toList(),
            );
          }
          else if(snapshot.connectionState == ConnectionState.done && snapshot.data!.isEmpty){
            return Center(child: Text('You have no message',style: TextStyle(fontSize: 30),),);
          }
          return Center(
            child: SizedBox(child: CircularProgressIndicator(),
            height: 30,width: 30,),
          );

        },
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  const MessageTile({
    Key? key,
    required this.username,
    required this.message,
    required this.time
  }) : super(key: key);

  final String username;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('$username'),
        subtitle: Row(
          children: [
            Text('$message'),
            Spacer(),
            Text('$time')
          ],
        ),
      ),
    );
  }
}


