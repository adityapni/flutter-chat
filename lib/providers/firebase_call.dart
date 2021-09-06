import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';


import 'app_user.dart';

class FirebaseCall with ChangeNotifier{

  FirebaseCall({
    this.username = '',
    this.mAppUser,
    this.otherPhone,
    required this.calling
  });

  final String? username;
  Stream<DocumentSnapshot<AppUser>>? mAppUser;
  String? otherPhone;
  bool calling;



  final appUserRev = FirebaseFirestore.instance.collection('Users').withConverter(
      fromFirestore: (snapshot, _) =>  AppUser.fromJson(snapshot.data()!),
      toFirestore: (appUser,_) => appUser.toJson()
  );

  doCall(String? phoneNumber){
    //update caller document
    appUserRev.doc('$username').set(AppUser(username: '$username',callingWho: '$phoneNumber',calledBy: null),
    SetOptions(merge: true));
    //update receiver document
    appUserRev.doc('$phoneNumber').set(AppUser(username: '$phoneNumber',callingWho: null,calledBy: '$username'),
    SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<AppUser>>? receiveCall() {

    mAppUser =  appUserRev.doc('$username').snapshots();
    notifyListeners();
    return mAppUser;

  }

  endCall() {
    appUserRev.doc('$username').set(AppUser(username: '$username',callingWho: null,calledBy: null),
        SetOptions(merge: true));

    appUserRev.doc('$otherPhone').set(AppUser(username: '$otherPhone',callingWho: null,calledBy: null),
        SetOptions(merge: true));
  }

  getOtherPhone() async {
    if(calling){
      otherPhone = await appUserRev.doc('$username').get().then((appUser) => appUser.data()!.callingWho);
    }
    if(!calling) {
      otherPhone = await appUserRev.doc('$username').get().then((appUser) => appUser.data()!.calledBy);
    }
    print('otherphone $otherPhone');
    notifyListeners();
  }

  createUser(){
    print('username $username');
    appUserRev.doc('$username').set(AppUser(username: '$username',callingWho: null,calledBy: null),
        SetOptions(merge: true));
  }
}