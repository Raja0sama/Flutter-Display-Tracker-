import 'package:flutter/material.dart';
import 'package:displaytracker/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:displaytracker/pages/maps.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  var data;
  var values = new List();
  var keys = new List();

  @override
  void initState() {
    super.initState();
    databaseReference.once().then((DataSnapshot snapshot) {
      var a = snapshot.value;
      data = a["users"];
      data.forEach((k, v) {
        setState(() {
          keys.add(k);
          values.add(v);
        });
      });
    });
  }

_navigateAndDisplaySelection(BuildContext context, String id) async {
      navigateToSubPage(context,id);
  }
Future navigateToSubPage(context,id) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Mapps(id)));
}
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter login demo'),
        ),
        body: new Column(
          children: <Widget>[
            Expanded(
             child: ListView(
                children: values
                    .map((item) => new ListTile(
                      onTap:()=>     _navigateAndDisplaySelection(context,item['trackerid'].toString()) ,
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(item['image']),
                          ),
                          title: Text(item['Name']),
                        ))
                    .toList(),
              ),
            )
          ],
        ));
  }


}

// class Post {
//   // Other functions and properties relevant to the class
//   // ......
//   /// Json is a Map<dynamic,dynamic> if i recall correctly.
//   static fromJson(json): Post {
//     Post p = new Post();
//     p.name = ...;
//     return p;
//   }
// }
