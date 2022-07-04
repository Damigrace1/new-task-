import 'dart:convert';
import '/widgets/showMaterialDialog.dart';
import 'globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class TimeLine extends StatefulWidget {
  final int indexId;
  final String date, time;
  TimeLine(this.indexId, this.date, this.time);
  @override
  _TimeLineState createState() => _TimeLineState(this.indexId, this.date, this.time);
}

class _TimeLineState extends State<TimeLine> {
  String fname = "YourName";
  var indexId;
  String date, time;
  var data;
  bool _progressBarActive = true;
  bool _nodata = false;
  String distance = "0";
  double totalDistance = 0.0;

  List<String> litems = ["1", "2", "Third", "4"];

  _TimeLineState(this.indexId, this.date, this.time);
  @override
  void initState() {
    super.initState();
    this.getEmployeeData();
  }

  Future<String> _getDistance(oldCoords, coords) async {
    if (oldCoords.toString() == "") oldCoords = "0,0";
    if (oldCoords.toString() == "0") oldCoords = "0,0";

    if (coords.toString() == "") coords = "0,0";

    List<String> oldGpsPosition = oldCoords.toString().split(",");
    List<String> gpsPosition = coords.toString().split(",");

    double distanceInMeters = await Geolocator().distanceBetween(
        double.tryParse(oldGpsPosition[0]),
        double.tryParse(oldGpsPosition[1]),
        double.tryParse(gpsPosition[0]),
        double.tryParse(gpsPosition[1]));
    setState(() => distance = distanceInMeters.toString());
    return distance;
  }

  @override
  Widget build(BuildContext context) {
    var dtnow = DateTime.now();
    var formattedDate = DateFormat.yMMMMd('en_US').format(dtnow);
    if (date != "") {
      var parsedDate = DateTime.parse(date + " 13:27:00");
      formattedDate = DateFormat.yMMMd('en_US').format(parsedDate);
    }


    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF52796F),
          title: new RichText(
            text: TextSpan(
              text: 'Timeline - ',
              style: TextStyle(fontSize: 14),
              children: <TextSpan>[
                TextSpan(
                    text: fname,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent)),
                TextSpan(text: " - " + formattedDate),
              ],
            ),
          )
          ,
        ),
        body: _progressBarActive == true
            ? _nodata == true
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "No timeline for the user right now",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.teal,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
            : Column(
                children: [
                  Chip(
                    backgroundColor: Colors.white,
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "Total distance:  ${data['distance']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        Text("Total time: ${data['hours']}", style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: new ListView.builder(
                          itemCount: data == null ? 0 : data["people"].length,
                          itemBuilder: (BuildContext context, int index) {
                            return new TimelineTile(
                              isLast:
                                  data["people"][index]["type"] == "Checked Out"
                                      ? true
                                      : false,
                              isFirst:
                                  data["people"][index]["type"] == "Checked In"
                                      ? true
                                      : false,
                              bottomLineStyle: LineStyle(
                                color: data["people"][index]["type"] == "Lunch"
                                    ? Colors.teal
                                    : data["people"][index]["type"] == "Reached"
                                        ? Colors.amber
                                        : data["people"][index]["type"] ==
                                                "Leaving"
                                            ? Colors.amber
                                            : data["people"][index]["type"] ==
                                                    "Checked In"
                                                ? Colors.green
                                                : Colors.green,
                                width: 4,
                              ),
                              indicatorStyle: IndicatorStyle(
                                iconStyle: data["people"][index]["type"] ==
                                        "Lunch"
                                    ? IconStyle(
                                        color: Colors.white,
                                        iconData: Icons.fastfood,
                                      )
                                    : data["people"][index]["type"] ==
                                            "Lunch End"
                                        ? IconStyle(
                                            color: Colors.white,
                                            iconData: Icons.fastfood,
                                          )
                                        : data["people"][index]["type"] ==
                                                "Checked In"
                                            ? IconStyle(
                                                fontSize: 23,
                                                color: Colors.white,
                                                iconData: Icons.flight_land,
                                              )
                                            : data["people"][index]["type"] ==
                                                    "Checked Out"
                                                ? IconStyle(
                                                    fontSize: 20,
                                                    color: Colors.white,
                                                    iconData:
                                                        Icons.flight_takeoff,
                                                  )
                                                : data["people"][index]
                                                            ["type"] ==
                                                        "Leaving"
                                                    ? IconStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                        iconData: Icons
                                                            .arrow_back_ios,
                                                      )
                                                    : data["people"][index]
                                                                ["type"] ==
                                                            "Reached"
                                                        ? IconStyle(
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                            iconData: Icons
                                                                .arrow_forward_ios,
                                                          )
                                                        : data["people"][index]
                                                                    ["type"] ==
                                                                "At Office"
                                                            ? IconStyle(
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white,
                                                                iconData: Icons
                                                                    .business,
                                                              )
                                                            : IconStyle(
                                                                fontSize: 20,
                                                                color: Colors
                                                                    .white,
                                                                iconData: Icons
                                                                    .directions_car,
                                                              ),

                                ///Make leaving and reaching
                                color: data["people"][index]["type"] ==
                                        "Checked In"
                                    ? Colors.green
                                    : data["people"][index]["type"] ==
                                            "Checked Out"
                                        ? Colors.red
                                        : data["people"][index]["type"] == "Job"
                                            ? Colors.amber
                                            : Colors.teal,
                                width: 25,
                                indicatorY: 0.2,
                                padding: EdgeInsets.all(8),
                              ),
                              alignment: TimelineAlign.manual,
                              lineX: 0.3,
                              rightChild: Container(
                                margin: EdgeInsets.fromLTRB(9, 0, 0, 0),
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onLongPress: data["people"][index]
                                                ["type"] ==
                                            "Checked Out"
                                        ? () {
                                      print("Checked Out");
                                            _showCheckOutDialog(
                                                "What do you want to do?");
                                          }
                                        :
                                    index == 0
                                            ?
                                        () {
                                      print("index 0");
                                      _showCheckInDialog(
                                                    "What do you want to do?");
                                              }
                                            : (){
                                      print("Not Admin");
                                    }
                                    ,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data["people"][index]["type"],
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        Text(data["people"][index]["address"]),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        index >= 1
                                            ? Text(
                                                "Distance: " +
                                                    data["people"][index]
                                                        ["notes"],
                                                style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontWeight: FontWeight.bold),
                                              )
                                            : globals.isAdminOnApp == true
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                    ],
                                                  )
                                                : Container(),
                                        if (index == data["people"].length - 1)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              leftChild: Container(
                                height: 80,
                                margin: EdgeInsets.fromLTRB(20, 5, 0, 0),
                                color: Colors.transparent,
                                child: Text(
                                  data["people"][index]["actiondate"]
                                      .toString()
                                      .substring(11, 16),
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
        floatingActionButton: globals.isAdminOnApp == true
            ? buildSpeedDial()
            : null
        );
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: true,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.flight_takeoff, color: Colors.white),
          backgroundColor: Colors.red,
          onTap: () {
            checkoutEmployee();
            getEmployeeData();
          },
          label: 'Checkout Employee',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.red,
        ),
        SpeedDialChild(
          child: Icon(Icons.cancel, color: Colors.white),
          backgroundColor: Colors.red,
          onTap: () {
            markEmployeeAbsent();
            getEmployeeData();
          },
          label: 'Mark Absent',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.red,
        ),
        SpeedDialChild(
          child: Icon(Icons.flight_takeoff, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () {
            resetEmployeeCheckOut();
            getEmployeeData();
          },
          label: 'Reset Checkout',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: Icon(Icons.circle, color: Colors.red),
          backgroundColor: Colors.red,
          onTap: () {
            checkinCheckoutUser("CHECKOUT");
          },
          label: 'Checkout',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.red,
        ),
        SpeedDialChild(
          child: Icon(Icons.flight_land, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () {
            resetEmployeeCheckIn();
            getEmployeeData();
          },
          label: 'Reset Checkin',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
        SpeedDialChild(
          child: Image.asset('assets/checkin.png'),
          backgroundColor: Colors.white,
          onTap: () {
          checkinCheckoutUser("CHECKIN");
          },
          label: 'Checkin',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),

      ],
    );
  }

  Future<String> resetEmployeeCheckOut() async {
    _progressBarActive = true;
    var map = Map<String, dynamic>();
    const _GET_TIMELINE_ = 'RESET_CHECKOUT';
    map['action'] = _GET_TIMELINE_;
    map['id'] = indexId.toString();


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
      var data6 = json.decode(response.body);

      print(data6);
      if (data6["result"] == 1) {
        _showMaterialDialog("Checkout deleted for the user");
        _progressBarActive = true;
      } else {
        _showMaterialDialog("Checkout delete error");
        _nodata = true;
        _progressBarActive = false;
      }
      getEmployeeData();
    });
    return "Success!";
  }

   checkinCheckoutUser(String action) async{
    _progressBarActive = true;
    var map = Map<String, dynamic>();
    map['action'] = action;
    map['id'] = indexId.toString();
    map['createdBy']='admin';
    map['notes'] = "";
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
    var data = jsonDecode(response.body);
    if(data['result']==1)
    DialogClass.showMaterialDialog(context,"${action.toLowerCase()} Successful",data['result']);

    else if(data['result']==2)
      DialogClass.showMaterialDialog(context,"This user has already ${action.toLowerCase()} for today",2);

  }


  Future<String> resetEmployeeCheckIn() async {
    _progressBarActive = true;
    var map = Map<String, dynamic>();
    const _GET_TIMELINE_ = 'RESET_CHECKIN';
    map['action'] = _GET_TIMELINE_;
    map['id'] = indexId.toString();
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
      var data6 = json.decode(response.body);

      print(data6);
      if (data6["result"] == 1) {
        _showMaterialDialog("Checkin deleted for the user");
        _progressBarActive = true;
      } else {
        _showMaterialDialog("Checkin delete error");
        _nodata = true;
        _progressBarActive = false;
      }
      getEmployeeData();
    });
    return "Success!";
  }

  Future<String> changeEmployeeCheckIn(String date) async {
    _progressBarActive = true;
    var map = Map<String, dynamic>();
    const _GET_TIMELINE_ = 'CHANGE_CHECKIN';
    map['action'] = _GET_TIMELINE_;
    map['id'] = indexId.toString();
    map['datetime'] = date;
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
      var data6 = json.decode(response.body);

      print(data6);
      if (data6["result"] == 1) {
        _showMaterialDialog("Check in modified for the user");
        _progressBarActive = true;

      } else {
        _showMaterialDialog("Check in modification error");
        _nodata = true;
        _progressBarActive = false;
      }
      getEmployeeData();
    });
    return "Success!";
  }

  Future<String> changeEmployeeCheckOut(String date) async {
    _progressBarActive = true;
    var map = Map<String, dynamic>();
    const _GET_TIMELINE_ = 'CHANGE_CHECKOUT';
    map['action'] = _GET_TIMELINE_;
    map['id'] = indexId.toString();
    map['datetime'] = date;
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
      var data6 = json.decode(response.body);

      print(data6);
      if (data6["result"] == 1) {
        _showMaterialDialog("Check out modified for the user");
        _progressBarActive = true;
      } else {
        _showMaterialDialog("Check out modification error");
        _nodata = true;
        _progressBarActive = false;
      }
      getEmployeeData();
    });
    return "Success!";
  }

  Future<String> checkoutEmployee() async {
    _progressBarActive = true;
    var map = Map<String, dynamic>();
    const _GET_TIMELINE_ = 'CHECKOUT';
    map['action'] = _GET_TIMELINE_;
    map['id'] = indexId.toString();
    map['address'] = "";
    map['notes'] = "";
    map['coords'] = "";

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
      var data6 = json.decode(response.body);

      print(data6);
      if (data6["result"] == 1) {
        _showMaterialDialog("User Checked out");
        _progressBarActive = true;
      } else {
        _showMaterialDialog("User Checkout Error");
        _nodata = true;
        _progressBarActive = false;
      }
      getEmployeeData();
    });
    return "Success!";
  }

  Future<String> markEmployeeAbsent() async {
    _progressBarActive = true;
    var map = Map<String, dynamic>();
    const _GET_TIMELINE_ = 'SET_OFF';
    map['action'] = _GET_TIMELINE_;
    map['id'] = indexId.toString();
    map['address'] = "";
    map['notes'] = "";
    map['coords'] = "";

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
      var data6 = json.decode(response.body);

      print(data6);
      if (data6["result"] == 1) {
        _showMaterialDialog("User marked as Absent");
        _progressBarActive = true;
      } else {
        _showMaterialDialog("Absent mark Error");
        _nodata = true;
        _progressBarActive = false;
      }
      getEmployeeData();
    });
    return "Success!";
  }

  _showMaterialDialog(String message) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
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
            ));
  }

  _showCheckOutDialog(String message) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Keep Connected"),
              content: new Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('Change checkout time'),
                  onPressed: () {
                    Navigator.of(context).pop();

                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onChanged: (date) {
                      print('change $date in time zone ' +
                          date.timeZoneOffset.inHours.toString());
                    }, onConfirm: (date) {
                      print('confirm $date');
                      changeEmployeeCheckOut(date.toString());
                    }, currentTime: DateTime.now());
                  },
                ),
              ],
            ));
  }

  _showCheckInDialog(String message) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text("Keep Connected"),
              content: new Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('Change checkin time'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true, onChanged: (date) {
                      print('change $date in time zone ' +
                          date.timeZoneOffset.inHours.toString());
                    }, onConfirm: (date) {
                      print('confirm $date');
                      changeEmployeeCheckIn(date.toString());
                    }, currentTime: DateTime.now());
                  },
                ),
              ],
            ));
  }

  Future<String> getEmployeeData() async {
    _progressBarActive = true;
    var map = Map<String, dynamic>();
    const _GET_TIMELINE_ = 'GET_TIMELINE';
    map['action'] = _GET_TIMELINE_;
    map['id'] = indexId.toString();
    map['date'] = date;

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
      print(data['distance']);
      if (data["result"] == 0) {
        _progressBarActive = true;
        _nodata = true;
      } else {
        for (var i = 0; i < data["people"].length; i++) {
          if (data["people"][i]["type"] == "CHECKIN")
            data["people"][i]["type"] = "Checked In";
          if (data["people"][i]["type"] == "CHECKOUT")
            data["people"][i]["type"] = "Checked Out";
          if (data["people"][i]["type"] == "LUNCHSTART")
            data["people"][i]["type"] = "Lunch";
          if (data["people"][i]["type"] == "LUNCHEND")
            data["people"][i]["type"] = "Lunch End";
          if (data["people"][i]["type"] == "LCHECKPOINT")
            data["people"][i]["type"] = "Leaving";
          if (data["people"][i]["type"] == "RCHECKPOINT")
            data["people"][i]["type"] = "Reached";
          if (data["people"][i]["type"] == "IN_OFF")
            data["people"][i]["type"] = "At Office";
          fname = data["people"][i]["fname"];

          if (i >= 1)
            if (data["people"][i]["notes"] != "" && data["people"][i]["notes"] != "0,0")
             _getDistance(data["people"][i - 1]["notes"], data["people"][i]["notes"]).then((value) {
               totalDistance = totalDistance + double.parse(value);
              if (double.parse(value) >= 1000) {
                double km = double.parse(value) / 1000;
                data["people"][i]["notes"] = km.roundToDouble().toString() + " kms";
              } else{
                data["people"][i]["notes"] = double.parse(value).roundToDouble().toString() + " mts";
              }
              if (i==data["people"].length-1){
                print("65 % of $totalDistance = ${0.65* totalDistance}");
              }
             });
        }
        _progressBarActive = false;
        fname = data["people"][0]["fname"];
      }
    });
    return "Success!";
  }
}
