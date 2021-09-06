import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/providers/app_user.dart';
import 'package:my_chat/providers/contact_provider.dart';
import 'package:my_chat/providers/firebase_call.dart';
import 'package:my_chat/screens/chat_room.dart';
import 'package:my_chat/screens/video_call.dart';
import 'package:provider/provider.dart';
import 'package:contacts_service/contacts_service.dart';

import 'loading.dart';

class Contacts extends StatelessWidget {

  Contacts({
    required this.mode
  });

  final String mode;

  @override
  Widget build(BuildContext context) {
    

    return ChangeNotifierProvider(
      create: (_) => ContactProvider(),
      builder: (context,child) {
        Iterable contacts = context.watch<ContactProvider>().contacts;
        if (contacts.isEmpty){
          return LoadingScreen();
        }
        return Scaffold(
        appBar: AppBar(
          actions: [IconButton(
              onPressed: (){
                showSearch(delegate: Search(contacts: contacts, mode: mode), context: context);
              },
              icon: Icon(Icons.search)
          )
          ],
        ),
        body: ContactList(contacts: contacts,mode: mode,)
      );
      }
    );
  }
}

class ContactList extends StatelessWidget {
  const ContactList({
    Key? key,
    required this.contacts,
    required this.mode
  }) : super(key: key);

  final Iterable contacts;
  final String mode;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => FirebaseCall(username: FirebaseAuth.instance.currentUser!.phoneNumber,
      calling: true),
      child: ListView(
          children: contacts
              .map((contact) => ContactTile(fullName: '${contact.displayName} ',
          phones: contact.phones, mode: mode,)).toList(),
        ),
    );
  }
}

class ContactTile extends StatelessWidget {
  const ContactTile({
    Key? key,
    this.fullName ,
    this.phones,
    required this.mode
  }) : super(key: key);

  final String? fullName;
  final Iterable<Item>? phones;
  final String mode;

  String? getPhoneNumber(){
    if (phones==null || phones!.isEmpty){
      return 'no phone';
    }

    return phones!.first.value;
  }

  call(phoneNumber, context){

    context.read<FirebaseCall>().doCall('$phoneNumber');

    Stream<DocumentSnapshot<AppUser>>? receiveCall = context.read<FirebaseCall>().receiveCall();


    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>
        MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (BuildContext context) => FirebaseCall(
                    username:FirebaseAuth.instance.currentUser!.phoneNumber,
                    calling: true),
              ),
              StreamProvider(create: (context)=> receiveCall,
                  initialData: null)
            ],
            child: VideoCall()
        )
    ));
  }

  chat({context,String? phoneNumber}){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ChatRoom(friend: phoneNumber,)));
  }

  @override
  Widget build(BuildContext context) {
     String? phoneNumber = getPhoneNumber();
     if ('$phoneNumber'.startsWith('0')){
       phoneNumber = '$phoneNumber'.replaceFirst('0', '+62');
     }


    return GestureDetector(
      onTap: (){
        if(mode=='call'){
          call(phoneNumber, context);
        }
        if(mode=='chat'){
          chat(context:context,phoneNumber: phoneNumber);
        }
      },
      child: Card(
        child: ListTile(
          title: Text('$fullName'),
          subtitle: Text('$phoneNumber') ,

        ),
      ),
    );
  }
}

class Search extends SearchDelegate{

  Search({
    required this.contacts,
    required this.mode
  });
  Iterable contacts;
  String mode;

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
          onPressed: (){
            query="";
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: (){
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back));
  }

  String? selectedResult;

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(child: Text('$selectedResult')),
    );
  }



  @override
  Widget buildSuggestions(BuildContext context) {
    List<dynamic> recentList = contacts.where((contact) => contact.displayName.contains('Neng')).toList();
    List<dynamic> suggestionList = [];
    query.isEmpty? suggestionList = recentList
        :suggestionList.addAll(
        contacts.where((contact) => contact.displayName.contains(query)));

    return ContactList(contacts: suggestionList,mode: mode,);
  }

}