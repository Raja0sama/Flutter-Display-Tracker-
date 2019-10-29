import 'package:flutter/material.dart';
import 'package:displaytracker/services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:displaytracker/pages/maps.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
  final myEmail = TextEditingController();
  final myPassword = TextEditingController();
  final myfullName = TextEditingController();

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

    databaseReference.child('users').onChildAdded.listen(_onEntryAdded);
    databaseReference.child('users').onChildChanged.listen(_onEntryAdded);
  }

  refresh() {
    setState(() {
          data = "";
    keys = [];
    values = [];
    });

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

  _onEntryAdded(Event event) {
    if (!mounted) return;
    print(event.snapshot.value);
    for (var i = 0; i < keys.length; i++) {
      if (event.snapshot.key == keys[i]) {
        setState(() {
          values[i] = event.snapshot.value;
        });
      } else {}
    }
    //  setState(() {
    //    keys.add(event.snapshot.key);
    //    values.add(event.snapshot.value);
    //   });
  }

  _navigateAndDisplaySelection(BuildContext context, String id) async {
    navigateToSubPage(context, id);
  }

  Future navigateToSubPage(context, id) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Mapps(id)));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('List of People'),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          IconButton(
            onPressed: refresh,
            icon: Icon(Icons.refresh),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: new Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              
              children: values
                  .map((item) => Card(
                          child: ListTile(
                          
                        onTap: () => _navigateAndDisplaySelection(
                            context, item['trackerid'].toString()),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(item['image']),
                        ),
                        title: Text(item['Name']),
                            trailing: item['Status'] == "Online" ? Icon(Icons.brightness_1,color: Colors.green,) : Icon(Icons.brightness_1,color: Colors.red,),
                        subtitle:  Text(  " 🎉 " +
                            item['trackerid'].toString()),
                      )))
                  .toList(),
            ),
          )
        ],
      ),
      floatingActionButton: new FloatingActionButton(
        child: Icon(
          Icons.add_box,
        ),
        onPressed: _showModalSheet,
        backgroundColor: Colors.orange,
      ),
    );
  }

  RegisterAUser(BuildContext context) async {
    try {
      var now = new DateTime.now();
      var formatter = new DateFormat('yyyyMMdd');
      String formatted = formatter.format(now);
      var rng = new Random();
      var create = await widget.auth.signUp(myEmail.text, myPassword.text);
      databaseReference.child('users').child(create).set({
        "Name": myfullName.text,
        "Status": "Offline",
        "image": 'https://img.icons8.com/plasticine/2x/user.png',
        "lastseen": formatted,
        "trackerid": int.parse(formatted) + rng.nextInt(100)
      });
      final scaffold = Scaffold.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('Successfully Created An Account'),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            child: Column(
              children: <Widget>[
                Text('Create a New Login ID'),
                TextField(
                  controller: myEmail,
                  decoration: InputDecoration(hintText: 'Enter a Email'),
                ),
                TextField(
                  controller: myfullName,
                  decoration: InputDecoration(hintText: 'Full Name'),
                ),
                TextField(
                  controller: myPassword,
                  obscureText: true,
                  decoration: InputDecoration(hintText: 'Enter a Password'),
                ),
                RaisedButton(
                  child: new Text('Create'),
                  onPressed: () {
                    RegisterAUser(context);
                  },
                )
              ],
            ),
            padding: EdgeInsets.all(40.0),
          );
        });
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
