//ToDo: company added to all api calls

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'one_month_dashboard.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;


class Staff extends StatefulWidget {
  @override
  _StaffState createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  var userID;
  var data;
  bool _progressBarActive = true;
  String name="";

  Future<String> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int company = int.tryParse((prefs.getString("company") ?? "0"));
    name= prefs.getString("username");
    userID=prefs.getString("userid");


    DateTime dtnow = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dtnow);

    var map = Map<String, dynamic>();
    const _GET_PEOPLE_ = 'GET_PEOPLE';
    String TODAY = formattedDate;
    map['action'] = _GET_PEOPLE_;
    map["date"] = TODAY;
    map["id"] = userID.toString();
    map['company'] = company.toString();
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
      data = json.decode(response.body);
      if (data["result"] == 0) data = null;
    });

    _progressBarActive = false;
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    _progressBarActive = true;
    this.getData();

  }

  @override
  Widget build(BuildContext context) {
    var dtnow = DateTime.now();
    var formattedDate = DateFormat.yMMMMd('en_US').format(dtnow);
    return new Scaffold(
      backgroundColor: const Color(0xFF52796F),
      appBar: new AppBar(
        title: new Text("Staff Directory"),
        backgroundColor: const Color(0xFF52796F),
        elevation: 0,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.calendar_today_outlined),
              onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context)=>OneMonthDashboard(username: name ,userId: userID.toString(),)));
          }),
          IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: () {
                getData();
              })
        ],
      ),
      body: _progressBarActive == true
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.teal,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    child: Text(formattedDate,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold))),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: data == null ? 0 : data["people"].length,
                      itemBuilder: (BuildContext context, int index) {
                        return new Card(
                            key: Key(data["people"][index]["phone"]),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 25),
                            color:
                                Colors.white,
                            child: ListTile(
                                leading: data["people"][index]["typeOfLeave"] ==
                                        "OFF"
                                    ? Text(data["people"][index]["fname"],
                                        style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ))
                                    : Text(data["people"][index]["fname"],
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                        )),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    data["people"][index]["typeOfLeave"] ==
                                            "OFF"
                                        ? Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                          )
                                        : data["people"][index]["type"] ==
                                                "CHECKIN"
                                            ? Icon(
                                                Icons.fiber_manual_record,
                                                color: Colors.greenAccent,
                                              )
                                            : data["people"][index]["type"] ==
                                                    "CHECKOUT"
                                                ? Icon(
                                                    Icons.fiber_manual_record,
                                                    color: Colors.redAccent,
                                                  )
                                                : data["people"][index]
                                                            ["type"] ==
                                                        "LCHECKPOINT"
                                                    ? Transform(
                                                        alignment:
                                                            Alignment.center,
                                                        transform:
                                                            Matrix4.rotationY(
                                                                math.pi),
                                                        child: Icon(
                                                          Icons.directions_walk,
                                                          color: Colors
                                                              .amberAccent,
                                                        ),
                                                      )
                                                    : data["people"][index]
                                                                ["type"] ==
                                                            "RCHECKPOINT"
                                                        ? Icon(
                                                            Icons
                                                                .directions_walk,
                                                            color: Colors
                                                                .amberAccent,
                                                          )
                                                        : data["people"][index]
                                                                    ["type"] ==
                                                                "IN_OFF"
                                                            ? Icon(
                                                                Icons.business,
                                                                color: Colors
                                                                    .green,
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .fiber_manual_record,
                                                                color: Colors
                                                                    .transparent,
                                                              ),
                                    SizedBox(
                                      width: 20,
                                    ),

                                    GestureDetector(
                                      child: Icon(Icons.phone),
                                      onTap: () {
                                        UrlLauncher.launch("tel://" +
                                            data["people"][index]["phone"]);
                                      },
                                    ),
                                    SizedBox(
                                      width: 40,
                                    ),
                                    GestureDetector(
                                      child: Icon(Icons.message),
                                      onTap: () {
                                        FlutterOpenWhatsapp.sendSingleMessage(
                                            data["people"][index]["phone"],
                                            "Hello, ");
                                      },
                                    )
                                  ],
                                )
                                ));
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(
            icon: Icons.contacts,
            text: 'Contacts',
          ),
          _createDrawerItem(
            icon: Icons.event,
            text: 'Events',
          ),
          _createDrawerItem(
            icon: Icons.note,
            text: 'Notes',
          ),
          Divider(),
          _createDrawerItem(icon: Icons.collections_bookmark, text: 'Steps'),
          _createDrawerItem(icon: Icons.face, text: 'Authors'),
          _createDrawerItem(
              icon: Icons.account_box, text: 'Flutter Documentation'),
          _createDrawerItem(icon: Icons.stars, text: 'Useful Links'),
          Divider(),
          _createDrawerItem(icon: Icons.bug_report, text: 'Report an issue'),
          ListTile(
            title: Text('0.0.1'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _createHeader() {
    return DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(color: Colors.teal),
        child: Stack(children: <Widget>[
          Positioned(
              bottom: 12.0,
              left: 16.0,
              child: Text("Keep Connected",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500))),
        ]));
  }

  Widget _createDrawerItem(
      {IconData icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }
}
