import 'dart:async';
import 'dart:convert';
import 'staffCheckIns.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
Route _createRouteReports(int indexId, String nameOfEmp) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        StaffCheckIn(indexId, nameOfEmp),
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

class Employee extends StatefulWidget {
  final int indexId;
  final int adminId;
  final String? date;

  Employee(this.indexId, this.adminId, [this.date]){
    print(this.date);
  }

  @override
  _EmployeeState createState() => _EmployeeState(this.indexId, this.adminId);
}

class _EmployeeState extends State<Employee> {
  String nameOfEmp = "empName";
  var offForToday = false;
  var indexId;
  int adminId;
  var data;
  var data2;
  bool _progressBarActive = true;
  bool _donotapprove = false;
  String _platformVersion = 'Unknown';
  bool _nodata = false;

  _EmployeeState(this.indexId, this.adminId);
  @override
  void initState() {
    super.initState();
    this.getEmployeeData(indexId);
  }

  @override
  Widget build(BuildContext context) {
    var deviceDate = MediaQuery.of(context);

    var dtnow = DateTime.now();
    var formattedDate = DateFormat.yMMMMd('en_US').format(dtnow);

    return Scaffold(
      backgroundColor: const Color(0xFF52796F),
      appBar: AppBar(
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                  icon: Icon(Icons.transfer_within_a_station),
                  onPressed: () => {
                        Navigator.of(context)
                            .push(_createRouteReports(indexId, nameOfEmp))

                      }))
        ],
        title: Text(widget.date==null?formattedDate:widget.date!,
            style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                letterSpacing: 2,
                fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF52796F),
        elevation: 0,
      ),
      body: _progressBarActive == true
          ? _nodata == true
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        data["fname"] + " " + data["lname"],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            letterSpacing: 3),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      height: (deviceDate.size.height) * 0.14,
                      width: deviceDate.size.width * 0.77,
                      child: Card(
                        color: Colors.white,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  data["phone"],
                                  style: TextStyle(
                                      color: Colors.teal,
                                      fontSize: 20,
                                      letterSpacing: 4),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    RaisedButton(
                                      color: Colors
                                          .teal, //const Color(0xFF1B4332),
                                      onPressed: () {
                                        UrlLauncher.launch(
                                            "tel://" + data["phone"]);
                                      },
                                      child: new Icon(
                                        Icons.call,
                                        color: Colors.white,
                                      ),
                                    ),
                                    RaisedButton(
                                      color: Colors
                                          .teal, // const Color(0xFF1B4332),
                                      onPressed: () async {
                                        await UrlLauncher.launch(
                                            "https://wa.me/${data["phone"]}?text=Hello");
                                      },
                                      child: new Icon(
                                        Icons.message,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: Text(
                        "No Data for the user right now",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: const Color(0xFF52796F),
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[

                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      data["people"][0]["fname"] +
                          " " +
                          data["people"][0]["lname"],
                      style: TextStyle(
                          color: Colors.white, fontSize: 25, letterSpacing: 2),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: (deviceDate.size.height) * 0.14,
                    width: deviceDate.size.width * 0.77,
                    child: Card(
                      color: Colors.white,
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                data["people"][0]["phone"],
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 20,
                                    letterSpacing: 4),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  RaisedButton(
                                    color:
                                        Colors.teal, //const Color(0xFF1B4332),
                                    onPressed: () {
                                      UrlLauncher.launch("tel://" +
                                          data["people"][0]["phone"]);
                                    },
                                    child: new Icon(
                                      Icons.call,
                                      color: Colors.white,
                                    ),
                                  ),
                                  RaisedButton(
                                    color:
                                        Colors.teal, // const Color(0xFF1B4332),
                                    onPressed: () async {
                                      await UrlLauncher.launch(
                                          "https://wa.me/${data["people"][0]["phone"]}?text=Hello");
                                    },
                                    child: new Icon(
                                      Icons.message,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: deviceDate.size.width * 0.7,
                    child: Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, deviceDate.size.width * 0.069, 0),
                    child: Table(
                      children: [
                        TableRow(children: [
                          Column(children: [
                            Icon(
                              Icons.alarm,
                              color: Colors.white,
                              size: 30,
                            ),
                          ]),
                          Column(children: [
                            data["people"][0]["task1"] == "1"
                                ? Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    actions: <Widget>[
                                      IconSlideAction(
                                          icon: Icons.timeline,
                                          caption: 'Timeline',
                                          color: Colors.blue,
                                          onTap: () {
                                            print("More is Clicked");
                                          }),
                                    ],
                                    secondaryActions: <Widget>[
                                      IconSlideAction(
                                          icon: Icons.clear,
                                          color: Colors.red,
                                          caption: 'Cancel',
                                          closeOnTap:
                                              false, //list will not close on tap
                                          onTap: () {
                                            print("More  is Clicked");
                                          })
                                    ],
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          data["people"][0]["task1Datetime"],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        data["people"][0]["t1gps"] != ""
                                            ? SizedBox.fromSize(
                                                size: Size(36, 36),
                                                child: ClipOval(
                                                  child: Material(
                                                    color: const Color(0xFF1B4332), // button color
                                                    child: InkWell(
                                                      splashColor: Colors.green, // splash color
                                                      onTap: () {
                                                        _showMaterialDialog(data["people"][0]["t1gps"], 0);
                                                      }, // button pressed
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.map,
                                                            color: Colors.white,
                                                          ), // icon
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox.fromSize(
                                                size: Size(36,
                                                    36), // button width and height
                                                child: ClipOval(
                                                  child: Material(
                                                    color: const Color(
                                                        0xFF1B4332), // button color
                                                    child: InkWell(
                                                      splashColor: Colors
                                                          .green, // splash color
                                                      onTap:
                                                          () {}, // button pressed
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.map,
                                                            color: Colors.grey,
                                                          ), // icon
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                      ],
                                    ),
                                  )
                                : Text(
                                    "Missed",
                                    style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                            SizedBox(
                              height: 30,
                            )
                          ]),
                        ]),
                        TableRow(children: [
                          Column(children: [
                            Icon(
                              Icons.note,
                              color: Colors.white,
                              size: 30,
                            ),
                          ]),
                          Column(children: [
                            data["people"][0]["task2"] == "1"
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        data["people"][0]["task2Datetime"],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      data["people"][0]["t2gps"] != ""
                                          ? SizedBox.fromSize(
                                              size: Size(36, 36),
                                              child: ClipOval(
                                                child: Material(
                                                  color: const Color(0xFF1B4332),
                                                  child: InkWell(
                                                    splashColor: Colors.green,
                                                    onTap: () {
                                                      _showMaterialDialog(
                                                          data["people"][0]
                                                              ["t2gps"],
                                                          0);
                                                    }, // button pressed
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.map,
                                                          color: Colors.white,
                                                        ), // icon
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox.fromSize(
                                              size: Size(36,
                                                  36), // button width and height
                                              child: ClipOval(
                                                child: Material(
                                                  color: const Color(
                                                      0xFF1B4332), // button color
                                                  child: InkWell(
                                                    splashColor: Colors
                                                        .green, // splash color
                                                    onTap:
                                                        () {}, // button pressed
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.map,
                                                          color: Colors.grey,
                                                        ), // icon
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                    ],
                                  )
                                : Text(
                                    "Missed",
                                    style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                            SizedBox(
                              height: 30,
                            )
                          ]),
                        ]),
                        TableRow(children: [
                          Column(children: [
                            Icon(
                              Icons.traffic,
                              color: Colors.white,
                              size: 30,
                            ),
                            //Text('My Account')
                          ]),
                          Column(children: [
                            //Icon(Icons.settings, size: 50,),
                            data["people"][0]["task3"] == "1"
                                ? GestureDetector(
                                    onLongPress: () {
                                      _showMaterialDialogToChangeLate(
                                          "Change this answer to ?", 23);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          data["people"][0]["task3Datetime"],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                        data["people"][0]["t3gps"] != ""
                                            ? SizedBox.fromSize(
                                                size: Size(36,
                                                    36), // button width and height
                                                child: ClipOval(
                                                  child: Material(
                                                    color: const Color(
                                                        0xFF1B4332), // button color
                                                    child: InkWell(
                                                      splashColor: Colors
                                                          .green, // splash color
                                                      onTap: () {
                                                        print("object");
                                                        _showMaterialDialog(
                                                            data["people"][0]
                                                                ["t3gps"],
                                                            0);
                                                      }, // button pressed
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.map,
                                                            color: Colors.white,
                                                          ), // icon
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox.fromSize(
                                                size: Size(36,
                                                    36), // button width and height
                                                child: ClipOval(
                                                  child: Material(
                                                    color: const Color(
                                                        0xFF1B4332), // button color
                                                    child: InkWell(
                                                      splashColor: Colors
                                                          .green, // splash color
                                                      onTap:
                                                          () {}, // button pressed
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.map,
                                                            color: Colors.grey,
                                                          ), // icon
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                      ],
                                    ),
                                  )
                                : data["people"][0]["task3"] == "2"
                                    ? GestureDetector(
                                        onLongPress: () {
                                          _showMaterialDialogToChangeLate(
                                              "Change this answer to ?", 13);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              data["people"][0]
                                                  ["task3Datetime"],
                                              style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 20),
                                            ),
                                            data["people"][0]["t3gps"] != ""
                                                ? SizedBox.fromSize(
                                                    size: Size(36,
                                                        36), // button width and height
                                                    child: ClipOval(
                                                      child: Material(
                                                        color: const Color(
                                                            0xFF1B4332), // button color
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .green, // splash color
                                                          onTap: () {
                                                            print("object");
                                                            _showMaterialDialog(
                                                                data["people"]
                                                                        [0]
                                                                    ["t3gps"],
                                                                0);
                                                          }, // button pressed
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Icon(
                                                                Icons.map,
                                                                color: Colors
                                                                    .white,
                                                              ), // icon
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox.fromSize(
                                                    size: Size(36,
                                                        36), // button width and height
                                                    child: ClipOval(
                                                      child: Material(
                                                        color: const Color(
                                                            0xFF1B4332), // button color
                                                        child: InkWell(
                                                          splashColor: Colors
                                                              .green, // splash color
                                                          onTap:
                                                              () {}, // button pressed
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Icon(
                                                                Icons.map,
                                                                color:
                                                                    Colors.grey,
                                                              ), // icon
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                          ],
                                        ),
                                      )
                                    : data["people"][0]["task3"] == "3"
                                        ? GestureDetector(
                                            onLongPress: () {
                                              _showMaterialDialogToChangeLate(
                                                  "Change this answer to ?",
                                                  33);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  data["people"][0]
                                                      ["task3Datetime"],
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                data["people"][0]["t3gps"] != ""
                                                    ? SizedBox.fromSize(
                                                        size: Size(36,
                                                            36), // button width and height
                                                        child: ClipOval(
                                                          child: Material(
                                                            color: const Color(
                                                                0xFF1B4332), // button color
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .green, // splash color
                                                              onTap: () {
                                                                print("object");
                                                                _showMaterialDialog(
                                                                    data["people"]
                                                                            [0][
                                                                        "t3gps"],
                                                                    0);
                                                              }, // button pressed
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Icons.map,
                                                                    color: Colors
                                                                        .white,
                                                                  ), // icon
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox.fromSize(
                                                        size: Size(36,
                                                            36), // button width and height
                                                        child: ClipOval(
                                                          child: Material(
                                                            color: const Color(
                                                                0xFF1B4332), // button color
                                                            child: InkWell(
                                                              splashColor: Colors
                                                                  .green, // splash color
                                                              onTap:
                                                                  () {}, // button pressed
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Icon(
                                                                    Icons.map,
                                                                    color: Colors
                                                                        .grey,
                                                                  ), // icon
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                              ],
                                            ),
                                          )
                                        : Text(
                                            "Missed",
                                            style: TextStyle(
                                                color: Colors.white60,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                            SizedBox(
                              height: 30,
                            )
                          ]),
                        ]),
                        if (offForToday == true)
                          TableRow(children: [
                            Column(children: [
                              Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 30,
                              ),
                              //Text('My Account')
                            ]),
                            Column(children: [
                              GestureDetector(
                                onLongPress: () {
                                  _showMaterialDialog(
                                      "Are you sure you want to delete this ?",
                                      int.tryParse(
                                          data["people"][0]["userid"])!);
                                },
                                child: Text(
                                  data["people"][0]["laddress"] +
                                      "\n" +
                                      data["people"][0]["ltime"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ]),
                          ]),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: deviceDate.size.width * 0.7,
                    child: Divider(
                      color: Colors.white,
                      thickness: 1,
                    ),
                  ),
                  Center(
                    child: ButtonBar(
                      alignment: MainAxisAlignment.center,
                      buttonHeight: 40,
                      buttonMinWidth: 100,
                      children: <Widget>[
                        RaisedButton(
                          color: const Color(0xFF1B4332),
                          padding: EdgeInsets.all(10),
                          elevation: 6,
                          onPressed: _donotapprove == true
                              ? null
                              : () {
                                  setDecision(
                                      "Approve",
                                      int.tryParse(
                                          data["people"][0]["userid"])!);
                                },
                          child: const Text('Approve',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                        RaisedButton(
                          color: const Color(0xFF1B4332),
                          padding: EdgeInsets.all(10),
                          splashColor: Colors.yellow[200],
                          elevation: 6,
                          onPressed: () {
                            setDecision("Decline",
                                int.tryParse(data["people"][0]["userid"])!);
                          },
                          child: const Text('Decline',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Colors.white,
        width: 4,
      ),
    );
  }

  Future<String> getEmployeeData(int id) async {
    _progressBarActive = true;
    DateTime dtnow = DateTime.now();
    String? formattedDate = widget.date==null?DateFormat('yyyy-MM-dd').format(dtnow):widget.date;
    //const _CREATE_TABLE_ACTION = 'CREATE_TABLE';
    var map = Map<String, dynamic>();
    const _GET_DETAILS_ = 'GET_DETAILS';
    map['action'] = _GET_DETAILS_;
    map['id'] = id.toString();
    map['date'] = formattedDate;
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

    data = json.decode(response.body);
    if (data["result"] == 0) {
      _progressBarActive = true;
      _nodata = true;
      getEmployee(id);
    } else {
      this.setState(() {
        nameOfEmp = data["people"][0]["fname"];
        data = json.decode(response.body);

        print(data);
        if (data["result"] == 0) {
          _progressBarActive = true;
          _nodata = true;
          getEmployee(id);
        } else {
          if (data["people"][0]["isOff"] == "1") {
            offForToday = true;
          }

          data["people"][0]["task1Datetime"] =
              data["people"][0]["task1Datetime"].toString().substring(11);
          data["people"][0]["task2Datetime"] =
              data["people"][0]["task2Datetime"].toString().substring(11);
          data["people"][0]["task3Datetime"] =
              data["people"][0]["task3Datetime"].toString().substring(11);
          //print(fwormattedDate);

          //if (data["people"][0]["task3"] == "0" ||
          //  data["people"][0]["task3"] == "3") _donotapprove = true;

          _progressBarActive = false;
        }
      });
    }

    //if()

    return "Success!";
  }

  Future<String> getEmployee(int id) async {
    //DateTime dtnow = DateTime.now();
    //String formattedDate = DateFormat('yyyy-MM-dd').format(dtnow);
    //const _CREATE_TABLE_ACTION = 'CREATE_TABLE';
    var map = Map<String, dynamic>();
    const _GET_DETAILS_ = 'GET_USER';
    map['action'] = _GET_DETAILS_;
    map['id'] = id.toString();
    //map['date'] = formattedDate;

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
      if (data["result"] == 0) {
        _progressBarActive = true;
        _nodata = true;
      } else {
        nameOfEmp = data["fname"];
      }
    });


    return "Success!";
  }

  Future<String> setDecision(String decision, int id) async {
    var map = Map<String, dynamic>();
    const _SET_DESC_ = 'SET_DESC';
    map['action'] = _SET_DESC_;
    map['id'] = id.toString();
    map['decision'] = decision;
    map['admin'] = adminId.toString();

    var response;
    var client = http.Client();
    try {
      response = await http.post(Uri.parse("https://www.keepconnected.duckdns.org/task/index.php"), body: map, headers: {"Accept": "application/json"});
    } finally {
      client.close();
    }
    this.setState(() {
      data2 = json.decode(response.body);
      _progressBarActive = false;
      if (data2["result"] == 1)
        _showMaterialDialog("Approved. Thank you", 0);
      else if (data2["result"] == 2)
        _showMaterialDialog("Declined. Thank you", 0);
      else
        _showMaterialDialog("Something went wrong. Please try again later", 0);
    });

    return "Success! ";
  }

  Future<String> deleteAbsent(int id) async {
    var map = Map<String, dynamic>();
    const _SET_DESC_ = 'DEL_ABS';
    map['action'] = _SET_DESC_;
    map['id'] = id.toString();

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
      data2 = json.decode(response.body);
      _progressBarActive = true;
      _nodata = true;
    });
    return "Success! ";
  }

  Future<String> changeLateTime(int id, int val) async {
    var map = Map<String, dynamic>();
    const _SET_DESC_ = 'CHANGE_LATE';
    map['action'] = _SET_DESC_;
    map['id'] = id.toString();
    map['val'] = val.toString();
    // map['decision'] = decision;

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
    data2 = json.decode(response.body);
    _progressBarActive = true;
    _nodata = true;
    print(data2);

    return "Success! ";
  }

  _showMaterialDialogToChangeLate(String message, int combination) {
    showDialog(
        context: context,
        builder: (_) => combination == 13
            ? new AlertDialog(
                title: new Text("Keep Connected"),
                content: new Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Change to on time'),
                    onPressed: () {
                      changeLateTime(indexId, 1).then((value) =>
                          getEmployeeData(indexId)
                              .then((value) => Navigator.of(context).pop()));
                    },
                  ),
                  FlatButton(
                    child: Text('Change to very late'),
                    onPressed: () {
                      changeLateTime(indexId, 3).then((value) =>
                          getEmployeeData(indexId)
                              .then((value) => Navigator.of(context).pop()));
                    },
                  )
                ],
              )
            : combination == 23
                ? new AlertDialog(
                    title: new Text("Keep Connected"),
                    content: new Text(message),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('Change to litte late'),
                        onPressed: () {
                          changeLateTime(indexId, 2).then((value) =>
                              getEmployeeData(indexId).then(
                                  (value) => Navigator.of(context).pop()));
                        },
                      ),
                      FlatButton(
                        child: Text('Change to very late'),
                        onPressed: () {
                          changeLateTime(indexId, 3).then((value) =>
                              getEmployeeData(indexId).then(
                                  (value) => Navigator.of(context).pop()));
                        },
                      )
                    ],
                  )
                : new AlertDialog(
                    title: new Text("Keep Connected"),
                    content: new Text(message),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('Change to on time'),
                        onPressed: () {
                          changeLateTime(indexId, 1).then((value) =>
                              getEmployeeData(indexId).then(
                                  (value) => Navigator.of(context).pop()));
                        },
                      ),
                      FlatButton(
                        child: Text('Change to little late'),
                        onPressed: () {
                          changeLateTime(indexId, 2).then((value) =>
                              getEmployeeData(indexId).then(
                                  (value) => Navigator.of(context).pop()));
                        },
                      )
                    ],
                  ));
  }

  _showMaterialDialog(String message, int delete) {
    showDialog(
        context: context,
        builder: (_) => delete == 0
            ? new AlertDialog(
                title: new Text("Keep Connected"),
                content: new Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              )
            : new AlertDialog(
                title: new Text("Keep Connected"),
                content: new Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('Delete'),
                    onPressed: () {
                      deleteAbsent(delete).then((value) => getEmployee(delete)
                          .then((value) => Navigator.of(context).pop()));
                    },
                  )
                ],
              ));
  }
}
