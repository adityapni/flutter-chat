
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_chat/auth/auth_service.dart';

import 'package:provider/provider.dart';

class PhoneAuth extends StatelessWidget {
 

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: Container(

        child: PhoneForm(),
      ),
    );
  }
}

class PhoneForm extends StatefulWidget {


  @override
  _PhoneFormState createState() => _PhoneFormState();
}



class _PhoneFormState extends State<PhoneForm> {


  final _formKey = GlobalKey<FormState>();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Form(
      key: _formKey,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30,),
              Text('Sign In with Phone',style: TextStyle(
                fontSize: 30,fontWeight: FontWeight.bold
              ),),
              Spacer(),
              SizedBox(
                height: size.width*0.3,
                width: size.width*0.3,
                child: FittedBox(child: Icon(Icons.phone,color: Colors.blue,),fit: BoxFit.fill,),
              ),
              Spacer(),
              Container(
                width: size.width * 0.9,
                child: TextFormField(
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'Please input your phone number';
                    }
                    return null;
                  },
                  controller: phoneNumberController,
                  decoration: InputDecoration(
                    hintText: 'Phone Number'
                  ),
                ),
              ),
              SizedBox(height: 10,),
              SizedBox(
                width: size.width*0.9,
                height: size.height*0.08,
                child: ElevatedButton(onPressed:(){
                 if (_formKey.currentState!.validate()) {
                    phoneLogin(phoneNumber: phoneNumberController.text);
                  }
                },

                  child: Text('Submit'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  phoneLogin({String? phoneNumber,}) async {
    String loginStatus  = await verifyPhoneNumber(phoneNumber: phoneNumber);
    debugPrint('login status : '+loginStatus);

  }

  Future<String> verifyPhoneNumber({String? phoneNumber}) async {
    try{
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '${phoneNumber}',
        verificationCompleted: handleAutoComplete,
        verificationFailed: handleFailed,
        codeSent: handleCode,
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: Duration(seconds: 60),
      );
      return 'Logged in with phone';
    } on FirebaseAuthException catch(e){
      return '${e.message}';
    }
  }

  handleAutoComplete(PhoneAuthCredential credential) async {
    // ANDROID ONLY!

    // Sign the user in (or link) with the auto-generated credential
    UserCredential result = context.read<AuthentificationProvider>().signIn(credential);
    Navigator.of(context).pop();

    // debugPrint('login user: '+result.user.toString());
  }

  handleFailed(FirebaseAuthException e) {
    if (e.code == 'invalid-phone-number') {
      print('The provided phone number is not valid.');
    }
    debugPrint('login error:${e.message}' );
    // Handle other errors
  }

  handleCode(String verificationId, int? resendToken) {
    var user = context.watch<User?>();
    if (user == null) {
      showDialog(context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Input verification code'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () {
                  AuthCredential credential = PhoneAuthProvider
                      .credential(verificationId: verificationId,
                      smsCode: codeController.text);
                  context.read<AuthentificationProvider>().signIn(credential);

                  Navigator.of(context).pop();
                },
                    child: Text('Confirm')),

              ],
            );
          });
    } if (user != null){
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }
}
