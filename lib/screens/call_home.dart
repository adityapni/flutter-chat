import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'contact.dart';

class CallHome extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final List<String> logs = <String>['One','Two','Three','Four'];

    return Scaffold(
      body: ListView.separated(
        padding: EdgeInsets.all(8),
        itemCount: logs.length,
        itemBuilder: (BuildContext context, int index){
          return Container(
            height: 50,
            child: Center(child: Text('Previous calls number ${logs[index]}'),),
          );
        },
        separatorBuilder: (BuildContext context, int index) => Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Contacts(mode: 'call',)));
        },
        child: Icon(Icons.phone),
      ),
    );
  }
}
