import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/providers/app_user.dart';
import 'package:my_chat/providers/firebase_call.dart';
import 'package:my_chat/screens/video_call.dart';
import 'package:provider/provider.dart';

class IncomingCall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Incoming Call'),
              SizedBox(height: 20,),
              ElevatedButton(
                  onPressed: () {
                    Stream<DocumentSnapshot<AppUser>>? receiveCall = context.read<FirebaseCall>().receiveCall();
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                            create: (BuildContext context) =>
                                FirebaseCall(calling: false,
                                    username: FirebaseAuth.instance.currentUser!
                                        .phoneNumber),
                          ),
                          StreamProvider(create: (context) =>
                              receiveCall,
                              initialData: null)
                        ],
                        child: VideoCall()
                    )
                ));

              },
                  child: Text('Answer'))
            ],
          ),
        ),
      ),
    );
  }
}
