import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/auth/wrapper.dart';
import 'package:my_chat/screens/home.dart';
import 'package:my_chat/screens/loading.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'auth/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch(e) {
      print(e.toString());
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if(_error) {
      print('error: firebase init failed');
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return   MaterialApp(
        title: 'Firebase Authentication',
        home: LoadingScreen(),
      );
    }

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    


    return MultiProvider(
      providers: [
        Provider<AuthentificationProvider>(
          create: (_) => AuthentificationProvider(auth),
        ),
        StreamProvider(
          create: (context) => context.read<AuthentificationProvider>().authStateChanges,
          initialData: auth.currentUser,)
      ],
      child: MaterialApp(
        title: 'My Chat',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: AuthenticationWrapper(),
      ),
    );
  }
}


