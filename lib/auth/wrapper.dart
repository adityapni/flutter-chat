import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_chat/screens/home.dart';
import 'package:my_chat/screens/phone.dart';
import 'package:provider/provider.dart';

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //Instance to know the authentication state.
    final firebaseUser = context.watch<User?>();

    // debugPrint('login user: '+firebaseUser.toString());

    if (firebaseUser != null){
      return HomePage();
    }
    return PhoneAuth();
  }
}
