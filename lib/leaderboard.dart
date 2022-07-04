import 'dart:async';
import 'dart:convert';
import 'pointHistory.dart';
import 'staffCheckIns.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'model/distance.dart';
import 'distancePage.dart';

class LeaderBoard extends StatefulWidget {
  @override
  _LeaderBoardState createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  String? currentMonth;
  final int userID = 1;
  var data;
  bool _progressBarActive = true;
  int totalPoints = 0;
  List<DistanceModel> nameAndDistanceList = [];

  Future<String> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String company = prefs.getString("company") ?? "0";
    var map = Map<String, dynamic>();
    const _GET_PEOPLE_ = 'GET_LEADERBOARD';
    // ignore: non_constant_identifier_names
    map['action'] = _GET_PEOPLE_;
    map['company'] = company;
    map["month"] = int.tryParse(currentMonth!).toString();
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
      data = json.decode(response.body);
      print(data);
      nameAndDistanceList = data['people']
          .map<DistanceModel>((e) => DistanceModel(e['fname'], e['total_distance']))
          .toList();
      if (data["points"] == 0)
        data = null;
      else {
        for (var i = 0; i < data["people"].length; i++) {
          totalPoints = totalPoints + data["people"][i]["points"] as int;
        }
      }
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
    var parsedDate = DateTime.parse("2020-" + currentMonth! + "-01 13:27:00");
    var formattedDate = DateFormat.MMMM('en_US').format(parsedDate);
    return new Scaffold(
      backgroundColor: const Color(0xFF52796F),
      appBar: new AppBar(
        title: new Text("Leaderboard"),
        backgroundColor: const Color(0xFF52796F),
        elevation: 0,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.directions_car_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context)=>DistancePage(data: nameAndDistanceList,month: formattedDate,))
                );
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      color: const Color(0xFF1B4332),
                      elevation: 5,
                      onPressed: () {
                        setState(() {
                          _progressBarActive = true;
                          totalPoints = 0;
                          String thisMonth = currentMonth;
                          if (int.parse(thisMonth) > 1) {
                            int valThisMonth = int.parse(thisMonth) - 1;
                            currentMonth = valThisMonth.toString().padLeft(2, "0");
                          }
                          this.getData();
                        });
                      },
                      child: Text(
                        "< Prev",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Text(formattedDate.toString(),
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
                          _progressBarActive = true;
                          totalPoints = 0;
                          String thisMonth = currentMonth;
                          if (int.parse(thisMonth) > 1) {
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
                ),
                Container(
                    child: Text("Points",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold))),
                SizedBox(
                  height: 20,
                ),
                Chip(
                  backgroundColor: Colors.white,
                  label: Text("Total Points: " + totalPoints.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Container(
                  child: Expanded(
                    child: data == null || data["people"] == null
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
                            itemCount: data == null ? 0 : data["people"].length,
                            itemBuilder: (BuildContext context, int index) {
                              return new Card(
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 25),
                                  color: Colors.white,
                                  child: ListTile(
                                    onLongPress: () {
                                      if (index > 0) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PointHistory(
                                                        int.parse(data["people"]
                                                                [index - 1]
                                                            ["userid"]),
                                                        data["people"]
                                                                [index - 1]
                                                            ['fname'])));
                                      }
                                    },
                                    onTap: () {
                                      if (index > 0) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    StaffCheckIn(
                                                        int.parse(data["people"]
                                                                [index - 1]
                                                            ["userid"]),
                                                        data["people"]
                                                                [index - 1]
                                                            ['fname'])));
                                      }
                                    },
                                    title: index == 0
                                        ? Text(
                                            "Name",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : index == 1
                                            ? Text(
                                                data["people"][index - 1]
                                                    ["fname"],
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : Text(data["people"][index - 1]
                                                ["fname"]),
                                    trailing: SizedBox(
                                      width: 80,
                                      child: Row(
                                        children: [
                                          Text(
                                            index == 0
                                                ? "hrs"
                                                : double.parse(data["people"]
                                                            [index - 1]["hours"]
                                                        .replaceAll(
                                                            "Hours", ""))
                                                    .round()
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Expanded(
                                            child: Container(),
                                          ),
                                          Text(
                                            index == 0
                                                ? "pts"
                                                : data["people"][index - 1]
                                                        ["points"]
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.end,
                                          ),
                                        ],
                                      ),
                                    ),
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
