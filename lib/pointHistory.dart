import 'dart:async';
import 'dart:convert';
import 'employee.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PointHistory extends StatefulWidget {
  final int indexId;
  final String name;

  PointHistory(this.indexId, this.name) {
    print(this.indexId);
    print(this.name);
  }

  @override
  _PointHistoryState createState() =>
      _PointHistoryState(this.indexId, this.name);
}

Route _createRoute(int id, int adminId, String date) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        Employee(id, adminId, date),
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

class _PointHistoryState extends State<PointHistory> {
  String currentMonth;
  final int userID = 1;
  var indexId;
  String name;
  var data;
  bool _progressBarActive = true;
  String formattedDate;
  int adminId;

  _PointHistoryState(this.indexId, this.name);

  Future<String> getData() async {
    DateTime dtnow = DateTime.now();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int company = int.tryParse((prefs.getString("company") ?? "0"));
    adminId = int.tryParse((prefs.getString("userid") ?? "0"));

    formattedDate = DateFormat('yyyy-MM-dd').format(dtnow);

    var map = Map<String, dynamic>();
    const _GET_PEOPLE_ = 'GET_POINTS';
    // ignore: non_constant_identifier_names
    String TODAY = formattedDate;
    map['action'] = _GET_PEOPLE_;
    map["id"] = indexId.toString();
    map['company'] = company.toString();
    map["month"] = currentMonth;
    print(map);
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
      print(data);
    });

    _progressBarActive = false;
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    _progressBarActive = true;
    DateTime dtnow = DateTime.now();

    currentMonth = DateFormat('MM').format(dtnow);
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    var parsedDate = DateTime.parse("2020-" + currentMonth + "-01 13:27:00");
    var thisMonth = DateFormat.MMMM('en_US').format(parsedDate);

    return new Scaffold(
      backgroundColor: const Color(0xFF52796F),
      appBar: new AppBar(
        title: new Text(
          "Points - " + name,
          style: TextStyle(fontSize: 15),
        ),
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
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      color: const Color(0xFF1B4332),
                      elevation: 5,
                      onPressed: () {
                        setState(() {
                          String thisMonth = currentMonth;
                          if (int.parse(thisMonth) > 1) {
                            int valThisMonth = int.parse(thisMonth) - 1;
                            currentMonth =
                                valThisMonth.toString().padLeft(2, "0");
                          }
                          this.getData();
                        });
                      },
                      child: Text(
                        "< Prev",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Text(thisMonth.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 4,
                            fontWeight: FontWeight.bold)),
                    RaisedButton(
                      elevation: 5,
                      color: const Color(0xFF1B4332),
                      onPressed: () {
                        setState(() {
                          String thisMonth = currentMonth;
                          if (int.parse(thisMonth) >= 1) {
                            int valThisMonth = int.parse(thisMonth) + 1;
                            currentMonth =
                                valThisMonth.toString().padLeft(2, "0");
                          }
                          this.getData();
                        });
                      },
                      child: Text(
                        "Next >",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                )),
                SizedBox(
                  height: 20,
                ),
                Chip(
                  backgroundColor: Colors.white,
                  label: Text("Total Points: ${data['total_points']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Container(
                  child: Expanded(
                    child: data == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "No data for the user right now",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            itemCount:
                                data == null ? 0 : data['payload'].length,
                            itemBuilder: (BuildContext context, int index) {
                              return formattedDate.toString().substring(0, 4) !=
                                      data['payload'][index]['date']
                                          .toString()
                                          .substring(0, 4)
                                  ? Container()
                                  : Card(
                                      elevation: 2,
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 25),
                                      color: Colors.white,
                                      child: ListTile(
                                          onLongPress: () {},
                                          onTap: () {
                                            Navigator.of(context).push(
                                                _createRoute(
                                                    int.tryParse(
                                                        data['payload'][index]
                                                            ["userid"]),
                                                    adminId,
                                                    data['payload'][index]
                                                        ["date"]));
                                          },
                                          title: Text(
                                              data['payload'][index]["date"],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(data['payload'][index]
                                              ["approve_by"]),
                                          trailing: Text(
                                            data['payload'][index]["points"]
                                                .toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    CupertinoColors.activeBlue,
                                                fontSize: 19),
                                          )));
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
