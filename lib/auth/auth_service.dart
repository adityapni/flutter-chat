

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class AuthentificationProvider{

  final FirebaseAuth _firebaseAuth;

  AuthentificationProvider(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();


  signOut() async{
    await _firebaseAuth.signOut();
  }

  signIn(AuthCredential credential) async{
    await _firebaseAuth.signInWithCredential(credential);
  }

  signUp({required String email, required String password}) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password
    );
  }

  emailSignIn({required String email, required String password}) async {
    UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password
    );
  }

}