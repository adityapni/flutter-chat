import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/auth/auth_service.dart';
import 'package:my_chat/providers/app_user.dart';
import 'package:my_chat/providers/firebase_call.dart';
import 'package:my_chat/screens/call_home.dart';
import 'package:my_chat/screens/chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'incoming_call.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  void initState() {
    super.initState();
    _askPermissions();
  }

  Future<void> _askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {

    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
      SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
  @override
  Widget build(BuildContext context) {

    String? username = context.read<User?>()!.phoneNumber;


    return MultiProvider(
      providers: [
        StreamProvider<DocumentSnapshot<AppUser>?>(
            create: ( context) => FirebaseCall(username: username,calling: false).receiveCall(),
            initialData: null,
        ),
        ChangeNotifierProvider<FirebaseCall>(
            create: (context)=>FirebaseCall(username: username,calling: false))
      ],
        child: HomeScreen()
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    //create user data
    context.read<FirebaseCall>().createUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    //receive incoming call
    DocumentSnapshot<AppUser>? snapshot = context.watch<DocumentSnapshot<AppUser>?>();
    AppUser? appUser;

    if (snapshot!=null){
      if (snapshot.exists ){
        appUser = snapshot.data();
      }
    }

    if (appUser != null){
      if (appUser.calledBy!=null  ){
        if(appUser.calledBy!.isNotEmpty) {
          return IncomingCall() ;
        }
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Chat',),
              Tab(text: 'Call',)
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Chat(),
            CallHome(),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children:[
              ListTile(title: Text('Sign Out'),
                onTap: (){
                  context.read<AuthentificationProvider>().signOut();
                },
              ),
            ]
        ),
        ),
      ),
    );
  }
}
