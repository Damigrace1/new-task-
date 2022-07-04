import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dashboard.dart';
import 'employee.dart';
import 'one_month_dashboard.dart';
import 'staffCheckIns.dart';
import 'timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';


class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

Route _createRoute(int? id) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TimeLine(id!, "", ""),
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

class _AdminState extends State<Admin> {
  String companyName = "YourCompany";
  int? userID;
  var data;
  bool _progressBarActive = true;

  Future<String> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? company = int.tryParse((prefs.getString("company") ?? "0"));
    userID = int.tryParse(prefs.getString("userid")!);
    DateTime dtnow = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(dtnow);
    var map = Map<String, dynamic>();
    const _GET_PEOPLE_ = 'GET_PEOPLE';
    // ignore: non_constant_identifier_names
    String TODAY = formattedDate;
    map['action'] = _GET_PEOPLE_;
    map["date"] = TODAY;
    map['company'] = company.toString();
    print(map);
    var response;
    var client = http.Client();
    try {
      response = await http.post(
          Uri.parse(
              "https://www.keepconnected.duckdns.org/task/index.php"),
          body: map,
          headers: {"Accept": "application/json"});
    } finally {
      client.close();
    }
    this.setState(() {
      companyName = prefs.getString("companyName") ?? "0";
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

  Route _dashboardRoute([String? name, String? userId, String? month]) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => month=="one"? Dashboard(username:name, userId: userId): OneMonthDashboard(username:name, userId: userId,),
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

  @override
  Widget build(BuildContext context) {
    var dtnow = DateTime.now();
    var formattedDate = DateFormat.yMMMMd('en_US').format(dtnow);
    return Scaffold(
      backgroundColor: const Color(0xFF52796F),
      appBar: new AppBar(
        title: new Text("Staff Status"),
        backgroundColor: const Color(0xFF52796F),
        elevation: 0,
        actions: <Widget>[
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
                            fontSize: 15,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold))),
                SizedBox(
                  height: 10,
                ),
                Container(
                    child: Text(companyName,
                        style: TextStyle(
                            color: Colors.orange[400],
                            fontSize: 12,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold))),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Expanded(
                    child: ListView.builder(
                      itemCount: data == null ? 0 : data["people"].length,
                      itemBuilder: (BuildContext context, int index) {
                        // print();
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          actions: <Widget>[
                            IconSlideAction(
                                icon: Icons.timeline,
                                caption: 'Dashboard',
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.of(context).push(_dashboardRoute(data["people"][index]['fname'],data["people"][index]['id'].toString()));
                                }),
                          ],

                          child: Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 25),
                              color: data["people"][index]
                                          ["validDateTimeStamp"] != "0000-00-00 00:00:00"
                                  ? data["people"][index]["total"] != "0"
                                      ? Colors.greenAccent
                                      : data["people"][index]["typeOfLeave"] == "OFF"
                                          ? Colors.white
                                          : Colors.red.shade200
                                  : Colors.white,

                              child: ListTile(
                                  onLongPress: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                        StaffCheckIn(int.parse(data["people"][index]['id']), data["people"][index]['fname'])));
                                  },
                                  onTap: () {
                                    int pass = int.tryParse(
                                        data["people"][index]["id"]) as int;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Employee(pass, userID!),
                                      ),
                                    );
                                  },
                                  trailing: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(_createRoute(
                                          int.tryParse(
                                              data["people"][index]["id"])));
                                    },
                                    child: SizedBox(
                                        child: Column(
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                    border: Border.all(width: 1)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(12.0),
                                                  child: data["people"][index]
                                                              ["typeOfLeave"] ==
                                                          "OFF"
                                                      ? Icon(
                                                          Icons.cancel,
                                                          color: Colors.red,
                                                        )
                                                      : data["people"][index]
                                                                  ["type"] ==
                                                              "CHECKIN"
                                                          ? Icon(
                                                              Icons
                                                                  .fiber_manual_record,
                                                              color: Colors.green,
                                                            )
                                                          : data["people"][index]
                                                                      ["type"] ==
                                                                  "CHECKOUT"
                                                              ? Icon(
                                                                  Icons
                                                                      .fiber_manual_record,
                                                                  color: Colors
                                                                      .redAccent,
                                                                )
                                                              : data["people"][index]
                                                                          [
                                                                          "type"] ==
                                                                      "LCHECKPOINT"
                                                                  ? Transform(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      transform: Matrix4
                                                                          .rotationY(
                                                                              math.pi),
                                                                      child: Icon(
                                                                        Icons
                                                                            .directions_walk,
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
                                                                      : data["people"][index]["type"] == "IN_OFF"
                                                                          ? Icon(
                                                                              Icons
                                                                                  .business,
                                                                              color:
                                                                                  Colors.green,
                                                                            )
                                                                          :
                                                  data["people"][index]["type"] == "LUNCHSTART"?Icon(Icons.lunch_dining, color: Colors.deepOrange,):
                                                  Icon(Icons.block),
                                                )),
                                            data["people"][index]["createdby"]=="admin"?
                                            Container(
                                              width: 35,
                                              height: 5,
                                              color:
                                              data["people"][index]
                                              ["type"] ==
                                                  "CHECKIN"?
                                              Colors.green:Colors.red,
                                            ):Container(
                                              width: 35,
                                              height: 5,),
                                          ],
                                        )),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 13,
                                    backgroundColor: Color(0xffFDCF09),
                                    child: CircleAvatar(
                                      radius: 13,
                                      backgroundImage: AssetImage(
                                          "assets/images/generic.png"),
                                    ),
                                  ),
                                  title: data["people"][index]["typeOfLeave"] ==
                                          "OFF"
                                      ? Text(data["people"][index]["fname"],
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 17,
                                            color: Colors.black,
                                          ))
                                      : Text(data["people"][index]["fname"],
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.black,
                                          )),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      data["people"][index]["task1"] == "1"
                                          ? Icon(
                                              CupertinoIcons
                                                  .check_mark_circled_solid,
                                              color: Colors.teal)
                                          : Icon(
                                              CupertinoIcons.check_mark_circled,
                                              color: Colors.teal),
                                      data["people"][index]["task2"] == "1"
                                          ? Icon(
                                              CupertinoIcons
                                                  .check_mark_circled_solid,
                                              color: Colors.teal)
                                          : Icon(
                                              CupertinoIcons.check_mark_circled,
                                              color: Colors.teal),
                                      data["people"][index]["task3"] == "1"
                                          ? Icon(
                                              CupertinoIcons
                                                  .check_mark_circled_solid,
                                              color: Colors.teal)
                                          : data["people"][index]["task3"] ==
                                                  "2"
                                              ? Icon(
                                                  CupertinoIcons
                                                      .check_mark_circled_solid,
                                                  color: Colors.orangeAccent)
                                              : data["people"][index]
                                                          ["task3"] ==
                                                      "3"
                                                  ? Icon(
                                                      CupertinoIcons
                                                          .check_mark_circled_solid,
                                                      color: Colors.redAccent)
                                                  : Icon(
                                                      CupertinoIcons
                                                          .check_mark_circled,
                                                      color: Colors.teal),

                                    ],
                                  )
                                  )),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

