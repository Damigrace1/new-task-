import 'dart:convert';
import 'dashboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class OneMonthDashboard extends StatefulWidget {
  final username, userId;
  const OneMonthDashboard({Key key, this.username, this.userId})
      : super(key: key);

  @override
  _OneMonthDashboardState createState() => _OneMonthDashboardState();
}

class _OneMonthDashboardState extends State<OneMonthDashboard> {
  final DateFormat dayFormatter = DateFormat("E");
  int month = DateTime.now().month;
  int presentOnTime = 0,
      littleLate = 0,
      late = 0,
      absent = 0,
      sunday = 0,
      nationalHoliday = 0,
      pendingAttendance = 0;
  List<DayTypeModel> descriptionData = [
    DayTypeModel(color: Colors.lightGreenAccent, type: "Present on time"),
    DayTypeModel(color: Colors.orangeAccent, type: "Little Late"),
    DayTypeModel(color: Colors.red, type: "Late"),
    DayTypeModel(
        type: "Absent",
        image: CircleAvatar(
          child: Icon(
            Icons.cancel,
            color: Colors.white,
            size: 20,
          ),
          backgroundColor: Colors.red,
          radius: 10,
        )),
    DayTypeModel(
        type: "Sunday",
        image: Image.asset(
          'assets/sunday_icon.png',
          height: 20,
          color: Colors.blue,
        )),
    DayTypeModel(color: Colors.lightBlueAccent, type: "National holiday"),
    DayTypeModel(color: Colors.grey, type: "Pending attendance"),
  ];

  @override
  void initState() {
    getDashboardData();
    super.initState();
  }

  List records;
  getDashboardData() async {
    var map = Map<String, dynamic>();
    const _GET_ATTENDANCE = 'GET_ATTENDANCE';
    map['id'] = widget.userId;
    map['action'] = _GET_ATTENDANCE;
    map['month'] = month.toString();
    http.Response response;
    var client = http.Client();
    try {
      print(map);
      response = await http.post(
          Uri.encodeFull(
              "https://www.keepconnected.duckdns.org/task/index.php"),
          body: map,
          headers: {"Accept": "application/json"});
      var data = jsonDecode(response.body);
      print(data);
      setState(() {
        records = data['data']['records'];
      });
      for (int i = 0; i < records.length; i++) {
        if (records[i]['dayName'] == 'Sun')
          sunday++;
        else if (records[i]['holiday'] != "")
          nationalHoliday++;
        else if (DateTime.parse(records[i]['curDate'])
                .isAfter(DateTime.now()) ==
            true)
          pendingAttendance++;
        else if (records[i]['punhin_time'] == null)
          absent++;
        else {
          DateTime data = DateTime.parse(records[i]['punhin_time']);
          if (data.hour > 10) {
            late++;
          } else if (data.hour >= 10 && data.minute > 15) {
            littleLate++;
          } else if ((data.hour <= 10 && data.minute <= 15) || data.hour < 10) {
            presentOnTime++;
          }
        }
      }
      descriptionData[0].count = presentOnTime;
      descriptionData[1].count = littleLate;
      descriptionData[2].count = late;
      descriptionData[3].count = absent;
      descriptionData[4].count = sunday;
      descriptionData[5].count = nationalHoliday;
      descriptionData[6].count = pendingAttendance;
    } finally {
      client.close();
    }
  }

  List<String> monthList =
      "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec".split(" ");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton(
            initialValue: month,
            onSelected: (_) {
              month = _;
              getDashboardData();
            },
            itemBuilder: (context) {
              return monthList
                  .map((e) => PopupMenuItem(
                        enabled:
                            DateTime.now().month >= monthList.indexOf(e) + 1,
                        child: Text(e),
                        value: monthList.indexOf(e) + 1,
                      ))
                  .toList();
            },
          )
        ],
      ),
      body: records == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Attendance Chart - ${widget.username}",
                      style: TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                  dayWiseTopRow(),
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: ListView.separated(
                      itemCount: records.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(bottom: 12, top: 12),
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: Text(
                                  records[index]['curDate'].toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                )),
                            Expanded(
                                flex: 2,
                                child: Text(
                                  records[index]['dayName'].toString(),
                                  textAlign: TextAlign.center,
                                )),
                            records[index]['createdby'] != null
                                ? Expanded(
                                    child: Text(records[index]["createdby"],
                                        textAlign: TextAlign.left))
                                : Expanded(child: Container()),
                            Expanded(
                                child: records[index]['dayName'] == 'Sun'
                                    ? Image.asset(
                                        "assets/sunday_icon.png",
                                        height: 20,
                                        color: Colors.blue,
                                      )
                                    : records[index]['holiday'] != ""
                                        ? CircleAvatar(
                                            backgroundColor:
                                                Colors.lightBlueAccent,
                                            radius: 10,
                                          )
                                        : (DateTime.parse(records[index]['curDate'])
                                                    .isAfter(DateTime.now()) ==
                                                true)
                                            ? CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                radius: 10,
                                              )
                                            : records[index]['punhin_time'] ==
                                                    null
                                                ? CircleAvatar(
                                                    child: Icon(
                                                      Icons.cancel,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    radius: 10,
                                                  )
                                                : CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor: DateTime.parse(
                                                                    records[index][
                                                                        "punhin_time"])
                                                                .hour >
                                                            10
                                                        ? Colors.red
                                                        : (DateTime.parse(records[index]['punhin_time'])
                                                                        .hour >=
                                                                    10) &&
                                                                (DateTime.parse(records[index]['punhin_time'])
                                                                        .hour <
                                                                    11) &&
                                                                (DateTime.parse(records[index]['punhin_time'])
                                                                        .minute >
                                                                    15)
                                                            ? Colors.orange
                                                            : Colors.lightGreenAccent))
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Colors.black,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    "Attendance calculation - ${widget.username}",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
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
                                      descriptionData[index - 1].type,
                                      textAlign: TextAlign.left,
                                    )),
                                    Expanded(
                                        child: descriptionData[index - 1]
                                                    .image ==
                                                null
                                            ? CircleAvatar(
                                                backgroundColor:
                                                    descriptionData[index - 1]
                                                        .color,
                                                radius: 8,
                                              )
                                            : descriptionData[index - 1].image),
                                    Expanded(
                                        child: Text(
                                      descriptionData[index - 1]
                                          .count
                                          .toString(),
                                      textAlign: TextAlign.end,
                                    )),
                                  ],
                                );
                        },
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: descriptionData.length + 1),
                  ),
                  SizedBox(
                    height: 8,
                  )
                ],
              ),
            ),
    );
  }

  Row dayWiseTopRow() {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Text(
              "Date",
              textAlign: TextAlign.center,
            )),
        Expanded(
            flex: 2,
            child: Text(
              "Day",
              textAlign: TextAlign.center,
            )),
        Expanded(
            child: Text(
          "Admin Action",
          textAlign: TextAlign.left,
        )),
        Expanded(
            child: Text(
          "Checkin",
          textAlign: TextAlign.center,
        )),
      ],
    );
  }

  Row monthlyTotal() {
    return Row(
      children: [
        Expanded(child: Text("Description")),
        // Expanded(child: Text("Colour")),
      ],
    );
  }
}
