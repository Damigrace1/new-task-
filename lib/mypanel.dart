import 'dart:convert';
import 'admin.dart';
import 'leaderboard.dart';
import 'post_announcements.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Mypanel extends StatefulWidget {

  @override
  _MypanelState createState() => _MypanelState();
}

enum Answers { CHECKIN, CHECKOUT, LUNCHSTART, LUNCHEND }


Route _createRouteMessagePost() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => MessagePost(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}


Route _createRouteLeaderBoard() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => LeaderBoard(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route _createRouteHomePage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route _createRoute1() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Admin(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class _MypanelState extends State<Mypanel> {
  String companyName = "YourName";
  bool isSuperAdmin = false;
  String notes;
  var indexId;
  var data;
  bool _progressBarActive = false;

  @override
  void initState() {
    super.initState();
    getInitialValues();
  }

  Future getInitialValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String superAdminVal = (prefs.getString("superAdmin") ?? "0");

    setState(() {
      companyName = (prefs.getString("companyName") ?? "0");

      if (superAdminVal == "1") isSuperAdmin = true;
    });
  }

  Future<String> setAction(String action) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _address = (prefs.getString("address") ?? "000");
    int id = int.tryParse((prefs.getString("userid") ?? "0"));
    String superAdminVal = (prefs.getString("superAdmin") ?? "0");

    if (superAdminVal == "1") isSuperAdmin = true;

    var map = Map<String, dynamic>();
    // ignore: non_constant_identifier_names
    String SETACT = action;
    map['action'] = SETACT;
    map['id'] = id.toString();
    map['address'] = _address;
    map['notes'] = notes;

    var response;
    var client = http.Client();
    try {
      response = await http.post(
          Uri.encodeFull(
              "https://www.keepconnected.duckdns.org/task/index.php"),
          body: map,
          headers: {"Accept": "application/json"});
    } finally {
      client.close();
    }
    this.setState(() {
      var data2 = json.decode(response.body);

      //print(data2);
      if (action == "CHECKIN") {
        if (data2["result"] == 1)
          _showMaterialDialog("Success: Check-In Successful. Have a good day!");
        else if (data2["result"] == 2)
          _showMaterialDialog(
              "Error: You already have one check-in for today.");
      } else if (action == "CHECKOUT") {
        if (data2["result"] == 1)
          _showMaterialDialog("Success: Check-Out Successful. See you soon!");
        else if (data2["result"] == 2)
          _showMaterialDialog("Error: You have to check-In for today");
        else if (data2["result"] == 3)
          _showMaterialDialog("Error: You have checked out for today");
      } else if (action == "CHECKPOINT") {
        if (data2["result"] == 1)
          _showMaterialDialog("Success: Added a new checkpoint");
        else if (data2["result"] == 2)
          _showMaterialDialog("Error: You have to check-In for today");
        else if (data2["result"] == 3)
          _showMaterialDialog("Error: You have checked out for today");
      } else if (action == "LUNCHSTART") {
        if (data2["result"] == 1)
          _showMaterialDialog("Success: Logged your start of Lunch");
        else if (data2["result"] == 2)
          _showMaterialDialog("Error: You have to check-In for today");
        else if (data2["result"] == 3)
          _showMaterialDialog(
              "Error: You already have logged your lunch today");
      } else if (action == "LUNCHEND") {
        if (data2["result"] == 1)
          _showMaterialDialog("Success: Logged your end of Lunch");
        else if (data2["result"] == 2)
          _showMaterialDialog("Error: You have to check-In for today");
        else if (data2["result"] == 3)
          _showMaterialDialog("Error: You have to log in your start of Lunch");
        else if (data2["result"] == 4)
          _showMaterialDialog(
              "Error: You have already logged your end of Lunch");
      }
    });

    return "Success!";
  }

  _showMaterialDialog(String message) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Task Tracker"),
              content: new Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  void showToast(String mesg) {
    Fluttertoast.showToast(
        msg: mesg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.black);
  }

  Future<String> changeAffiliation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int company = int.tryParse((prefs.getString("company") ?? "0"));
    int id = int.tryParse((prefs.getString("userid") ?? "0"));
    showToast("Please Wait");

    var map = Map<String, dynamic>();
    // ignore: non_constant_identifier_names
    String SETACT = "CHANGE_AFF";
    map['action'] = SETACT;
    map['id'] = id.toString();


    var client = http.Client();
    var response;
    try {
      response = await client.post(
          Uri.encodeFull(
              "https://www.keepconnected.duckdns.org/task/index.php"),
          body: map,
          headers: {"Accept": "application/json"});
    } finally {
      client.close();
    }


    this.setState(() {
      var data2 = json.decode(response.body);
      if (data2["result"] != 0) {
        showToast("Success");
        Navigator.of(context).push(_createRouteHomePage());
      } else
        showToast("Error Please try again");
    });

    return "Success!";
  }

  @override
  Widget build(BuildContext context) {
    var dtnow = DateTime.now();
    var formattedDate = DateFormat.yMMMMd('en_US').format(dtnow);

    return Scaffold(
      backgroundColor: const Color(0xFF52796F),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Admin Panel ",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF52796F),
        elevation: 0,
      ),
      body: _progressBarActive == true
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.teal,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(formattedDate,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 10,
                    ),
                    Text(companyName,
                        style: TextStyle(
                            color: Colors.orange[400],
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.of(context).push(_createRoute1()),
                            child: Card(
                              elevation: 20,
                              margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.person_solid,
                                      size: 45,
                                      color: Colors.teal,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Staff Status",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(_createRouteMessagePost());
                            },
                            child: Card(
                              margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      CupertinoIcons.mail_solid,
                                      size: 45,
                                      color: Colors.teal,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "New Announcement",
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),


                      ],
                    ),
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (isSuperAdmin) changeAffiliation();
                              },
                              child: Card(
                                margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        CupertinoIcons.refresh_thick,
                                        size: 45,
                                        color: isSuperAdmin == true
                                            ? Colors.teal
                                            : Colors.grey,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Switch",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(_createRouteLeaderBoard());
                              },
                              child: Card(
                                margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: 45,
                                        color: Colors.teal,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        "Leaderboard",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
