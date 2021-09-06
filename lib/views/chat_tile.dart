import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  const ChatTile({
    Key? key,
    required this.username,
    required this.message,
    required this.time
  }) : super(key: key);

  final String? username;
  final String? message;
  final String? time;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width*0.7),
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: IntrinsicWidth(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                      child: Text('$username',style: TextStyle(fontSize: 15,color: Colors.green),)),
                  SizedBox(height: 2,),
                  Align(
                    alignment: Alignment.centerLeft,
                      child: Text('$message',style: TextStyle(fontSize: 15),)),
                  // SizedBox(height: 5,),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('$time',style: TextStyle(fontSize: 12,),),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10,)
      ],
    );

  }
}