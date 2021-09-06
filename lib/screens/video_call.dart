import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_chat/providers/app_user.dart';
import 'package:my_chat/providers/firebase_call.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:my_chat/agora/token.dart';
import 'package:http/http.dart' as http;

import 'package:permission_handler/permission_handler.dart';

/// Define App ID and Token
const APP_ID = '4e8fd56f22a2469a9f023a485ea76827';
const channelName = 'test%20channel';

class VideoCall extends StatefulWidget {
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {

  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;
  String rtcToken = '';
  String otherPhone='';
  late RtcEngine engine;

  @override
  void dispose() {
    engine.destroy();
    super.dispose();
  }



  @override
  void initState() {
    super.initState();
    initPlatformState();

  }

  Future<void> fetchToken(String? uid) async {

    String tokenUrl = 'https://pacific-waters-58063.herokuapp.com/rtc/${channelName}/_/uid/$uid/?3600';
    print('token url $tokenUrl');
    final response =
    await http.get(Uri.parse(tokenUrl));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Token token =  Token.fromJson(jsonDecode(response.body));
      rtcToken = token.rtcToken;

      print('rtc token $rtcToken');
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load rtc token');
    }
  }

  getOtherPhone(){
    context.read<FirebaseCall>().getOtherPhone();
    otherPhone = '${context.watch<FirebaseCall>().otherPhone}';
    print('other phone $otherPhone');
  }

  // Init the app
  Future<void> initPlatformState() async {
    await [Permission.camera, Permission.microphone].request();

    String? _uid = FirebaseAuth.instance.currentUser!.phoneNumber;
    _uid = _uid!.replaceAll('+', '');

    await fetchToken(_uid);

    // Create RTC client instance
    RtcEngineConfig config = RtcEngineConfig(APP_ID);
    engine = await RtcEngine.createWithConfig(config);
    // Define event handling logic
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('joinChannelSuccess ${channel} ${uid}');
          setState(() {
            _joined = true;
          });
        }, userJoined: (int uid, int elapsed) {
      print('userJoined ${uid}');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline ${uid}');
      setState(() {
        _remoteUid = 0;
      });
    },
    ));
    // Enable video
    await engine.enableVideo();
    // Join channel with channel name as 123
    await engine.joinChannel(rtcToken, 'test channel', null, int.parse(_uid));

    await getOtherPhone();
  }





  @override
  Widget build(BuildContext context) {


    bool calling = context.read<FirebaseCall>().calling;
    print('calling $calling');

    if (!calling){
      DocumentSnapshot<AppUser>? snapshot = context.watch<DocumentSnapshot<AppUser>?>();
      AppUser? appUser;
      if (snapshot!=null){
        if (snapshot.exists ){
          appUser = snapshot.data();
        }
      }

      if (appUser != null){
        if (appUser.calledBy==null  ){
          return CallEnded();
        }
        if (appUser.calledBy!=null  ){
          if(appUser.calledBy!.isEmpty) {
            return CallEnded();
          }
        }
      }
    }




    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<FirebaseCall>().endCall();
        Navigator.pop(context);
      },
        child: Icon(Icons.phone),
        backgroundColor: Colors.red,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          Center(
            child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _switch = !_switch;
                  });
                },
                child: Center(
                  child:
                  _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
  // Local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      return Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }
  }

class CallEnded extends StatelessWidget {
  const CallEnded({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Call Ended'),
            ElevatedButton(onPressed: (){
              Navigator.pop(context);
            }
                , child: Text('Close'))
          ],
        ),
      ),
    );
  }
}



