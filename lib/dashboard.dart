//ToDo: company added to all api calls


import 'dart:convert';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/time.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  final username, userId;
  const Dashboard({ this.username, this.userId});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<DayTypeModel> descriptionData = [
    DayTypeModel(color: Colors.green, type: "Present on time"),
    DayTypeModel(color: Colors.deepOrangeAccent, type: "Little Late"),
    DayTypeModel(color: Colors.red, type: "Late"),
    DayTypeModel(color: Colors.redAccent, type: "Absent"),
    DayTypeModel(color: Colors.lightBlueAccent, type: "Sunday"),
    DayTypeModel(color: Colors.blue, type: "National holiday"),
  ];

  late String _currentMonth, _previousMonth, _secondLastMonth;
  DateTime now = DateTime.now();
  late int daysCurrentMonth, daysPreviousMonth, daysSecondLastMonth, thisYear, thisMonth;
  final DateFormat dayFormatter = DateFormat("E");
  final DateFormat monthFormatter = DateFormat("MMMM");
  var dateUtility = DateUtil();
  late List currentMonthRecords, previousMonthRecords, secondLastMonthRecords;

  @override
  void initState() {
    thisYear = now.year;
    thisMonth = now.month;
    daysCurrentMonth = daysInMonth(thisYear, thisMonth);
    daysPreviousMonth = daysInMonth(thisYear, thisMonth - 1);
    daysSecondLastMonth = daysInMonth(thisYear, thisMonth - 2);
    _currentMonth = monthFormatter.format(now);
    _previousMonth = monthFormatter.format(DateTime(thisYear, thisMonth - 1));
    _secondLastMonth = monthFormatter.format(DateTime(thisYear, thisMonth - 2));
    getDashboardData();
    super.initState();
  }

  getDashboardData() async {
    var map = Map<String, dynamic>();
    const _GET_ATTENDANCE = 'GET_ATTENDANCE';
    map['id'] = widget.userId.toString();
    map['action'] = _GET_ATTENDANCE;
    map['toDate'] = DateTime.now().toString();

    http.Response response;
    var client = http.Client();
    try {
      print(map);
      response = await http.post(Uri.parse("https://www.keepconnected.duckdns.org/task/index.php"),
          body: map, headers: {"Accept": "application/json"});
      var data = jsonDecode(response.body);
      setState(() {
        currentMonthRecords = jsonDecode(data['data']['records']);
      });
      print(currentMonthRecords.length);
      currentMonthRecords.forEach((element) { print(element['curDate']);});
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Three Months Attendance Chart - ${widget.username}",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
            ),
            Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 12, top: 12),
                  itemBuilder: (context, index) {
                    return index == 0
                        ? dayWiseTopRow()
                        : Row(
                            children: [
                              Expanded(
                                  child: Text(
                                daysSecondLastMonth >= index
                                    ? index.toString()
                                    : "",
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              )),
                              Expanded(
                                  child: Text(
                                      daysSecondLastMonth >= index
                                          ? dayFormatter.format(DateTime.utc(
                                              thisYear, thisMonth - 2, index))
                                          : "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                      ))),
                              Expanded(
                                  child: daysSecondLastMonth >= index
                                      ? CircleAvatar(
                                          backgroundColor: dayFormatter.format(
                                                      DateTime.utc(
                                                          thisYear,
                                                          thisMonth - 2,
                                                          index)) !=
                                                  "Sun"
                                              ? Colors.green
                                              : Colors.lightBlueAccent,
                                          radius: 8,
                                        )
                                      : Container()),
                              Expanded(
                                  child: Text(
                                      daysPreviousMonth >= index
                                          ? index.toString()
                                          : "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                      ))),
                              Expanded(
                                  child: Text(
                                      daysPreviousMonth >= index
                                          ? dayFormatter.format(DateTime.utc(
                                              thisYear, thisMonth - 1, index))
                                          : "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                      ))),
                              Expanded(
                                  child: daysPreviousMonth >= index
                                      ? CircleAvatar(
                                          backgroundColor: dayFormatter.format(
                                                      DateTime.utc(
                                                          thisYear,
                                                          thisMonth - 1,
                                                          index)) !=
                                                  "Sun"
                                              ? Colors.green
                                              : Colors.lightBlueAccent,
                                          radius: 8,
                                        )
                                      : CircleAvatar()),
                              Expanded(
                                  child: Text(
                                      daysCurrentMonth >= index
                                          ? index.toString()
                                          : "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                      ))),
                              Expanded(
                                  child: Text(
                                      daysCurrentMonth >= index
                                          ? dayFormatter.format(DateTime.utc(
                                              thisYear, thisMonth, index))
                                          : "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                      ))),
                              Expanded(
                                  child: daysCurrentMonth >= index
                                      ? CircleAvatar(
                                          backgroundColor: dayFormatter.format(
                                                      DateTime.utc(thisYear,
                                                          thisMonth, index)) !=
                                                  "Sun"
                                              ? Colors.green
                                              : Colors.lightBlueAccent,
                                          radius: 8,
                                        )
                                      : Container()),
                            ],
                          );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      color: Colors.black,
                    );
                  },
                  itemCount: daysPreviousMonth > daysCurrentMonth &&
                          daysPreviousMonth > daysSecondLastMonth
                      ? daysPreviousMonth + 1
                      : daysCurrentMonth > daysPreviousMonth &&
                              daysCurrentMonth > daysSecondLastMonth
                          ? daysCurrentMonth + 1
                          : daysSecondLastMonth),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              "Three Months Attendance calculation - ${widget.username}",
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            SizedBox(
              height: 6,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 2,
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 12, top: 12),
                  itemBuilder: (context, index) {
                    return index == 0
                        ? monthlyTotal()
                        : Row(
                            children: [
                              Expanded(
                                  child: Text(
                                descriptionData[index - 1].type??'',
                                textAlign: TextAlign.left,
                              )),
                              Expanded(
                                  child: CircleAvatar(
                                backgroundColor:
                                    descriptionData[index - 1].color,
                                radius: 8,
                              )),
                              Expanded(
                                  child: Text(
                                index.toString(),
                                textAlign: TextAlign.center,
                              )),
                              Expanded(
                                  child: Text(
                                index.toString(),
                                textAlign: TextAlign.center,
                              )),
                              Expanded(
                                  child: Text(
                                index.toString(),
                                textAlign: TextAlign.center,
                              )),
                            ],
                          );
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: 7),
            ),
            SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }

  Row monthlyTotal() {
    return Row(
      children: [
        Expanded(child: Text("Description")),
        Expanded(child: Text("Colour")),
        Expanded(child: Text(_secondLastMonth)),
        Expanded(child: Text(_previousMonth)),
        Expanded(child: Text(_currentMonth)),
      ],
    );
  }

  Row dayWiseTopRow() {
    return Row(
      children: [
        Expanded(
            child: Text(
          "Date",
          textAlign: TextAlign.center,
        )),
        Expanded(
            child: Text(
          "Day",
          textAlign: TextAlign.center,
        )),
        Expanded(
            child: Text(
          _secondLastMonth,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        )),
        Expanded(
            child: Text(
          "Date",
          textAlign: TextAlign.center,
        )),
        Expanded(
            child: Text(
          "Day",
          textAlign: TextAlign.center,
        )),
        Expanded(
            child: Text(_previousMonth,
                textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
        Expanded(
            child: Text(
          "Date",
          textAlign: TextAlign.center,
        )),
        Expanded(
            child: Text(
          "Day",
          textAlign: TextAlign.center,
        )),
        Expanded(
            child: Text(_currentMonth,
                textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class DayTypeModel {
  String? type;
  Color? color;
  int? count;
  Widget?image;
  Widget? icon;

  DayTypeModel({this.type, this.color, this.count, this.image, this.icon});
}
