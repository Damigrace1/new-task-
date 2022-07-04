import 'dart:async';
import 'dart:convert';
import 'timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class StaffCheckIn extends StatefulWidget {
  final int indexId;
  final String name;

  StaffCheckIn(this.indexId, this.name);

  @override
  _StaffCheckInState createState() =>
      _StaffCheckInState(this.indexId, this.name);
}

Route _createRoute(int id, String date, String time) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => TimeLine(id, date, time),
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

class _StaffCheckInState extends State<StaffCheckIn> {
  String currentMonth;
  final int userID = 1;
  var indexId;
  String name;
  var data;
  bool _progressBarActive = true;
  String formattedDate;

  _StaffCheckInState(this.indexId, this.name);

  Future<String> getData() async {
    DateTime dtnow = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int company = int.tryParse((prefs.getString("company") ?? "0"));
    int id = int.tryParse((prefs.getString("userid") ?? "0"));

    formattedDate = DateFormat('yyyy-MM-dd').format(dtnow);

    var map = Map<String, dynamic>();
    const _GET_PEOPLE_ = 'GET_CHECKINS';
    String TODAY = formattedDate;
    map['action'] = _GET_PEOPLE_;
    map["id"] = indexId.toString();
    map["month"] = currentMonth;
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
          "Checkin times - " + name,
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
                          //DateTime dtnow = DateTime.now();
                          //DateTime monthago = dtnow.subtract(new Duration())
                          //currentMonth = DateFormat('MM').format(dtnow);
                          //currentMonth = ;
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
                )),
                SizedBox(
                  height: 20,
                ),
                Chip(
                  backgroundColor: Colors.white,
                  label: data != null
                      ? Text('Total Hours in the Month: ' +
                          data["people"][0]["Total"])
                      : Text("No data"),
                  labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
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
                            itemCount: data == null ? 0 : data["people"].length,
                            itemBuilder: (BuildContext context, int index) {
                              return
                                formattedDate.toString().substring(0,4)!=data['people'][index]['date'].toString().substring(0,4)?Container():
                                Card(
                                  // key: Key(data["people"][index]["phone"]),
                                  elevation: 2,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 25),
                                  color: Colors.white,

                                  // Colors.greenAccent: Colors.white,
                                  child: ListTile(

                                      //isThreeLine: true,
                                      subtitle: RichText(
                                        text: TextSpan(
                                          //text: data["people"][index]["checkin"]
                                          //  .toString()
                                          //.substring(10),
                                          style: TextStyle(color: Colors.green),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: data["people"][index]
                                                        ["checkin"]
                                                    .toString()
                                                    .substring(10),
                                                style: TextStyle(
                                                    color: Colors.green)),
                                            TextSpan(
                                                text: " - ",
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            TextSpan(
                                                text: data["people"][index]
                                                        ["checkout"]
                                                    .toString()
                                                    .substring(10),
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),

                                      /* Text(data["people"][index]["checkin"]
                                        .toString()
                                        .substring(10) +
                                    " - " +
                                    data["people"][index]["checkout"]
                                        .toString()
                                        .substring(10)), */
                                      onLongPress: () {},
                                      onTap: () {
                                        Navigator.of(context).push(_createRoute(
                                            int.tryParse(data["people"][index]
                                                ["userid"]),
                                            data["people"][index]["date"]
                                                .toString(),
                                            data["people"][index]["hours"]));
                                      },
                                      title: Text(data["people"][index]["date"],
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                      trailing: Text(
                                        data["people"][index]["hours"].toString().substring(0,5),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.activeBlue,
                                            fontSize: 19),
                                        /*  new Text(
                                                       data["people"][index]["fname"] +
                                                           " " +
                                                           data["people"][index]["lname"],
                                                       style: TextStyle(fontSize: 20),
                                                     ) */
                                      )));
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  /*  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat.yMd().format(_selectedDateTime);
    final selectedText = Text('You selected: $formattedDate');

    final birthdayTile = new Container(
      color: Colors.transparent,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Birthday',
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 15.0,
              )),
          const Padding(
            padding: EdgeInsets.only(bottom: 5.0),
          ),
          CupertinoDateTextBox(
              color: Colors.white,
              fontSize: 20,
              initialValue: _selectedDateTime,
              onDateChange: onBirthdayChange,
              hintText: DateFormat.yMd().format(_selectedDateTime)),
        ],
      ),
    );

    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text("Admin"),
      ),
      backgroundColor: Colors.teal,
      body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
          child: Column(children: <Widget>[
            //selectedText,
            //const SizedBox(height: 15.0),
            birthdayTile
          ])),
    );
  } */

  /* void onBirthdayChange(DateTime birthday) {
    setState(() {
      _selectedDateTime = birthday;
    });
  } */
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
