import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'widgets/showMaterialDialog.dart';
import 'package:http/http.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'globals.dart' as globals;
import 'mypanel.dart';
import 'staffdirectory.dart';
import 'timeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import 'firstcard/card.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location_platform_interface/location_platform_interface.dart'
as loc2;
export 'package:location_platform_interface/location_platform_interface.dart'
    show PermissionStatus, LocationAccuracy, LocationData;
import 'model/message.dart';


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');

  const AndroidNotificationChannel channel=AndroidNotificationChannel('high-importance_channel', 'high importance notification',importance: Importance.high);
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

Route _createRouteTimeLine(int id) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        TimeLine(id, "", ""),
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
    pageBuilder: (context, animation, secondaryAnimation) => Staff(),
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

Route _mypanelRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Mypanel(),
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final FirebaseMessaging _messaging =FirebaseMessaging.instance;
  final List<Message> messages = [];
  var snackBar;
  bool showExtension = false;
  final version = "v1.5.5 ";
  var anns;
  bool annsExist = false;
  bool disableAll = false;
  bool expireCards = false;
  bool sunday = false;
  bool dialVisible = true;
  bool cheat = false;
  bool isLoaded = false;
  String? _timeString;
  String fname = "YourName";
  String address = "";
  bool connError = true;
  bool loggedIn = false;
  bool isAdmin = false;
  bool finalDesc = false;
  int descApproved = 2;
  String lastAction = "";
  bool isCheckedOut = false;
  bool isAutoCheckOut = false;
  bool isSuperAdmin = false;
  SharedPreferences? sharedPreferences;
  int? userID;
  ConfettiController? _controllerCenter;
  int _counter = 0;
  String _bString = "000";
  Color? color, color1, colorFourthCard, color3;
  late Color fontColor;
  late Icon iconCheck, icon1, iconFourthCard, icon3;
  String bValues = "000";
  String cName = "YourCompany";
  var gpsPosition;
  String nextAction = "";
  String logo =
      "https://cdn3.iconfinder.com/data/icons/UltimateGnome/256x256/emblems/emblem-generic.png";
  bool toggleColor = false;
  RoundedRectangleBorder shape1 = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15.0),
  );
  bool askForLocation = false;
  var setActionData;
  static DateTime dtnow = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-ddb').format(dtnow);
  late String company;

  prefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? company = int.tryParse((prefs.getString("company") ?? "0"));
    this.company = company.toString();
  }

  Widget getScoreDetails() {
    return Container(
      width: 350,
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getIndicatorCard('Absent',"1"),
              getIndicatorCard('Little Late',"0"),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getIndicatorCard('Very Late', "4"),
            ],
          ),
        ],
      ),
    );
  }

  Padding getIndicatorCard(String text, String num) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: new BoxDecoration(
              color: const Color(0xFF52796F),
            ),
            child: Text(num, style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ),
          Text(
            text,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Muli",
            ),
          ),
        ],
      ),
    );
  }

  getToken()async{
    String? token=await FirebaseMessaging.instance.getToken();
    print(token);
  }
  @override
  void initState() {
    prefs();
    getToken();
    _messaging.(
      onMessage: (Map<String, dynamic> message) async {
        final notification = message['notification'];
        setState(() {
          showSimpleAlertDialog(
              context, notification['body'], notification['title']);
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        final notification = message['data']['message'];
        Map<String, dynamic> mess = jsonDecode(notification);

        setState(() {
          showSimpleAlertDialog(context, '${mess['body']}', '${mess['title']}');

          messages
              .add(Message(title: '${mess['title']}', body: '${mess['body']}'));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        final notification = message['data']['message'];
        Map<String, dynamic> mess = jsonDecode(notification);

        setState(() {
          showSimpleAlertDialog(context, '${mess['body']}', '${mess['title']}');

          messages
              .add(Message(title: '${mess['title']}', body: '${mess['body']}'));
        });
      },
    );
    _timeString = _formatDateTime(DateTime.now());

    sunday = false;

    if (DateFormat('EEEE').format(DateTime.now()) == "Sunday") sunday = true;

    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 10));
    super.initState();
    _getCurrentLocation();
    checkLoginStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);

    setState(() {
      _timeString = formattedDateTime;
      if (anns != null) toggleColor = !toggleColor;
    });
    if (dtnow.isAfter(DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 18, 45)) &&
        !isCheckedOut &&
        !isAutoCheckOut) {
      isAutoCheckOut = true;
      setAction("CHECKOUT");
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('H:mm:ss').format(dateTime);
  }

  Future<bool> checkIfLocationOn() {
    var serviceStatus = loc2.LocationPlatform.instance.serviceEnabled();
    return serviceStatus;
  }

  Future<bool> _getDistance() async {
    double distanceInMeters = await Geolocator().distanceBetween(
        28.525894, 77.260344, gpsPosition.latitude, gpsPosition.longitude);

    if (distanceInMeters < 100)
      return true;
    else
      return false;
  }

  Future<bool> _getCurrentLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool serviceStatus = await loc2.LocationPlatform.instance.serviceEnabled();

    if (serviceStatus == false) {
      DialogClass.showMaterialDialog(
          context, "Turn ON your location services", 0);
      return false;
    }
    setState(() {
      dtnow = DateTime.now();
      formattedDate = DateFormat('yyyy-MM-ddb').format(dtnow);
      nextAction =
      (prefs.getString("nextAction_" + formattedDate) ?? "CHECKIN");

      if (nextAction == "CHECKIN") showExtension = false;

      address = "Please wait..";
    });

    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    gpsPosition = position;
    prefs.setString(
        "coords",
        gpsPosition.latitude.toString() +
            "," +
            gpsPosition.longitude.toString());

    List<Placemark> p = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = p[0];
    var _currentAddress;
    _currentAddress =
    "${place.name}, ${place.subLocality}, ${place.locality} ,${place.postalCode}";
    address = _currentAddress;
    prefs.setString("address", address);

    return true;
  }

  _getAddressFromLatLng(lat, long) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      List<Placemark> p =
      await Geolocator().placemarkFromCoordinates(lat, long);

      Placemark place = p[0];
      var _currentAddress;
      setState(() {
        _currentAddress =
        "${place.name}, ${place.subLocality}, ${place.locality} ,${place.postalCode}";

        address = _currentAddress;

        prefs.setString("address", address);
        showToast("Location Updated");
      });
    } catch (e) {}
  }

  checkLoginStatus() async {
    isLoaded = false;
    sunday = false;

    if (DateFormat('EEEE').format(DateTime.now()) == "Sunday") sunday = true;

    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("userid") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Login()),
              (Route<dynamic> route) => false);
    } else {
      userID = (int.tryParse(sharedPreferences.getString("userid")));
      getFname();
      _messaging.getToken().then((token) {
        saveDevToken(token);

        loggedIn = true;

        isStillOff();
        getScore();
        getAnnouncements();
        _loadCounter();
        _checkIfTimePassed();
        Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
      });
    }
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      checkLoginStatus();
      if (state == AppLifecycleState.paused) _incrementCounter();
      if (state == AppLifecycleState.resumed) {
        isStillOff();
        _getCurrentLocation();
        _checkIfTimePassed();
        getAnnouncements();
      }
    });
  }

  void showToast(String mesg) {
    ToastGravity gravity = ToastGravity.CENTER;
    Fluttertoast.showToast(
        msg: mesg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: gravity,
        backgroundColor: Colors.white,
        textColor: Colors.black);
  }

  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      dtnow = DateTime.now();
      formattedDate = DateFormat('yyyy-MM-ddb').format(dtnow);
      _bString = (prefs.getString(formattedDate) ?? "000");
    });
  }

  _incrementCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      dtnow = DateTime.now();
      formattedDate = DateFormat('yyyy-MM-ddb').format(dtnow);
      prefs.setString(formattedDate, _bString);
      prefs.setInt('counter', _counter);
    });
  }

  SpeedDial buildSpeedDial() {
    final endTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 15);

    final currentTime = DateTime.now();
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      backgroundColor: const Color(0xFF1B4332),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        isAdmin == true
            ? SpeedDialChild(
            child: Icon(Icons.lock, color: Colors.teal),
            backgroundColor: Colors.white,
            onTap: () {
              Navigator.of(context).push(_mypanelRoute());
            },
            label: 'Admin',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 15),
            labelBackgroundColor: Colors.teal,
            foregroundColor: Colors.white)
            : SpeedDialChild(
            child: Icon(CupertinoIcons.person_solid, color: Colors.teal),
            backgroundColor: Colors.white,
            onTap: () => Navigator.of(context).push(_createRoute1()),
            label: 'Who is In',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 15),
            labelBackgroundColor: Colors.teal,
            foregroundColor: Colors.white),
        SpeedDialChild(
            child: Icon(Icons.flight_land, color: Colors.teal),
            backgroundColor:
            disableAll == false ? Colors.white : Colors.grey[400],
            onTap: () {
              disableAll == false ? setAction("CHECKIN") : print("Sorry");
            },
            label: 'Check-In',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15),
            labelBackgroundColor: Colors.teal,
            foregroundColor: Colors.white),
        SpeedDialChild(
            child: Icon(Icons.business, color: Colors.teal),
            backgroundColor:
            disableAll == false ? Colors.white : Colors.grey[400],
            onTap: () {
              if (disableAll == false) {
                if (checkIfLocationOn() != null)
                  setAction("IN_OFF");
                else
                  showToast("TURN ON YOUR LOCATION");
              }
            },
            label: 'At Office',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15),
            labelBackgroundColor: Colors.teal,
            foregroundColor: Colors.white),
        SpeedDialChild(
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.teal,
          ), //  Icons.flight_takeoff, color: Colors.teal),
          backgroundColor:
          disableAll == false ? Colors.white : Colors.grey[400],
          onTap: () {
            disableAll == false ? setAction("LCHECKPOINT") : print("Sorry");
          },
          label: 'Leaving Checkpoint',
          labelStyle: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15),
          labelBackgroundColor: Colors.teal,
        ),
        SpeedDialChild(
          child: Icon(
            Icons.arrow_forward_ios,
            color: Colors.teal,
          ), //  Icons.flight_takeoff, color: Colors.teal),
          backgroundColor:
          disableAll == false ? Colors.white : Colors.grey[400],
          onTap: () {
            disableAll == false ? setAction("RCHECKPOINT") : print("Sorry");
          },
          label: 'Reaching Checkpoint',
          labelStyle: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15),
          labelBackgroundColor: Colors.teal,
        ),
        SpeedDialChild(
          child: Icon(Icons.flight_takeoff, color: Colors.teal),
          backgroundColor:
          disableAll == false ? Colors.white : Colors.grey[400],
          //onTap: () => setAction("CHECKOUT"),
          onTap: () {
            disableAll == false ? setAction("CHECKOUT") : print("Sorry");
          },
          label: 'Checkout',
          labelStyle: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15),
          labelBackgroundColor: Colors.teal,
        ),
        currentTime.isBefore(endTime)
            ? SpeedDialChild(
            child: Icon(Icons.cancel, color: Colors.red),
            backgroundColor:
            disableAll == false ? Colors.white : Colors.grey[400],
            onTap: () => disableAll == false ? setAction("SET_OFF") : null,
            label: 'Not Coming to office today',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 15),
            labelBackgroundColor: Colors.teal,
            foregroundColor: Colors.white)
            : SpeedDialChild(
            child: Icon(Icons.cancel, color: Colors.black),
            backgroundColor: Colors.grey,
            label: 'Not Coming to office today',
            labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 15),
            labelBackgroundColor: Colors.teal,
            foregroundColor: Colors.white),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    dtnow = DateTime.now();
    formattedDate = DateFormat.yMMMMd('en_US').format(dtnow);
    return isLoaded == false
        ? Scaffold(
        backgroundColor: const Color(0xFF52796F),
        body: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.teal,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ))
        : Scaffold(
      appBar: buildAppBar(),
      backgroundColor: const Color(0xFF52796F),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.white,
            ),
          ],
        ),
        child: BottomNavigationBar(
            selectedItemColor: const Color(0xFF1B4332),
            unselectedItemColor: const Color(0xFF1B4332),
            elevation: 0,
            backgroundColor: Colors.white,
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
                if (_currentIndex == 0) {
                  CupertinoActionSheet act = actionSheet(context);
                  showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext context) => act);
                } else if (_currentIndex == 2) {
                  if (isAdmin)
                    Navigator.of(context).push(_mypanelRoute());
                  else
                    Navigator.of(context).push(_createRoute1());
                } else if (_currentIndex == 1) {
                  Navigator.of(context)
                      .push(_createRouteTimeLine(userID));
                }
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: new Icon(Icons.compare_arrows),
                label: 'Actions',
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.map),
                label: 'My Timeline',
              ),
              BottomNavigationBarItem(
                  icon: isAdmin == true
                      ? Icon(Icons.https)
                      : Icon(Icons.person),
                  label: isLoaded == false
                      ? ""
                      : isAdmin == true
                      ? "Admin"
                      : 'Who\'s In?')
            ]),
      ),
      body: loggedIn == false
          ? Center(
        child: CircularProgressIndicator(
          backgroundColor: Colors.teal,
          valueColor:
          new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Builder(
        builder: (context) => SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              25, 0, 0, 0),
                          child: Container(
                              child: Text(
                                  "Karo India Foundation Initiative",
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 15,
                                      letterSpacing: 2,
                                      fontWeight:
                                      FontWeight.bold))),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Chip(
                        backgroundColor: Colors.transparent,
                        avatar: CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(logo)),
                        label: Text(cName),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Container(
                              child: Text("Hello " + fname,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      letterSpacing: 0,
                                      fontWeight:
                                      FontWeight.bold))),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                            child: Text("It's " + formattedDate,
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 17,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.bold))),
                      ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // Container(
                      //     child: Text(_timeString,
                      //         style: TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 17,
                      //             letterSpacing: 0,
                      //             fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 20,
                        width: 350,
                        child:LinearPercentIndicator(
                          //leaner progress bar
                          animation: true,
                          animationDuration: 1000,
                          lineHeight: 20.0,
                          percent: 80 / 100,
                          center: Text(
                            80.toString() + "%",
                            style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          linearStrokeCap: LinearStrokeCap.roundAll,
                          progressColor: Colors.red[400],
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      getScoreDetails()
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
                child: Divider(
                  color: Colors.teal.shade100,
                ),
                width: double.infinity,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                    child: Row(
                      children: [
                        Text("Announcements",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                letterSpacing: 0,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: 10,
                        ),
                        anns['anns'][0]['id'] != 0 && anns != null
                            ? AnimatedContainer(
                          height: 20,
                          width: 20,
                          duration: Duration(seconds: 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: toggleColor
                                ? Colors.yellow
                                : Colors.orangeAccent,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            anns["anns"].length.toString(),
                            style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                            : Container()
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
                    child: Text("My Points: $_counter",
                        style: TextStyle(
                            color: descApproved == 1
                                ? Colors.lightGreen
                                : descApproved == 0
                                ? Colors.red
                                : Colors.white,
                            fontSize: 17,
                            letterSpacing: 0,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              buildColumnForMessages(),
              SizedBox(
                height: 20,
              ),
              buildColumnForWfh(),
              SizedBox(
                height: 20,
              ),
              expireCards == false
                  ? Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(
                          25, 0, 0, 0),
                      child: Text("My Tasks",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              letterSpacing: 0,
                              fontWeight: FontWeight.bold))),
                ],
              )
                  : Container(),
              expireCards == false
                  ? buildColumnForCards()
                  : Container(),
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: _controllerCenter,
                  blastDirectionality: BlastDirectionality
                      .explosive, // don't specify a direction, blast randomly
                  shouldLoop:
                  false, // start again as soon as the animation is finished
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple
                  ], // manually specify the colors to be used
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CupertinoActionSheet actionSheet(BuildContext context) {
    final endTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 15);

    final currentTime = DateTime.now();

    final act = CupertinoActionSheet(
        title: Text('What do you want to do?'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: disableAll == false
                ? nextAction == "WORKFROMHOME"
                ? Text('Work From Home',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold))
                : Text('Work From Home')
                : Text('Work From Home',
                style: TextStyle(
                  color: Colors.grey,
                )),
            onPressed: () {
              if (disableAll == false) {
                showToast("Please Wait");
                _getCurrentLocation().then((value) {
                  if (value) setAction("WORKFROMHOME");
                });
              }
              cancelActionSheet(context);
            },
          ),
          CupertinoActionSheetAction(
            child: disableAll == false
                ? nextAction == "REMOVE_WFH"
                ? Text('Remove Work From Home',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold))
                : Text('Remove Work From Home')
                : Text('Remove Work From Home',
                style: TextStyle(
                  color: Colors.grey,
                )),
            onPressed: () {
              if (disableAll == false) {
                showToast("Please Wait");
                _getCurrentLocation().then((value) {
                  if (value) setAction("REMOVE_WFH");
                });
              }
              cancelActionSheet(context);
            },
          ),
          CupertinoActionSheetAction(
            child: disableAll == false
                ? nextAction == "LUNCHSTART"
                ? Text('Lunch',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold))
                : Text('Lunch')
                : Text('Lunch',
                style: TextStyle(
                  color: Colors.grey,
                )),
            onPressed: () {
              if (disableAll == false) {
                showToast("Please Wait");
                _getCurrentLocation().then((value) {
                  if (value) setAction("LUNCHSTART");
                });
              }
              cancelActionSheet(context);
            },
          ),
          if (currentTime.isBefore(endTime))
            CupertinoActionSheetAction(
              child: disableAll == false
                  ? Text('Absent')
                  : Text('Absent',
                  style: TextStyle(
                    color: Colors.grey,
                  )),
              onPressed: () {
                if (disableAll == false) {
                  showToast("Please Wait");
                  _getCurrentLocation().then((value) {
                    if (value) setAction("SET_OFF");
                  });
                }
                cancelActionSheet(context);
              },
            ),
          CupertinoActionSheetAction(
            child: disableAll == false
                ? nextAction == "CHECKOUT"
                ? Text('Checkout',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold))
                : Text('Checkout')
                : Text('Checkout',
                style: TextStyle(
                  color: Colors.grey,
                )),
            onPressed: () {
              if (disableAll == false) {
                showToast("Please Wait");
                _getCurrentLocation().then((value) {
                  if (value) setAction("CHECKOUT");
                });
              }
              cancelActionSheet(context);
            },
          ),
          CupertinoActionSheetAction(
            child: disableAll == false
                ? nextAction == "RCHECKPOINT"
                ? Text('Reaching Checkpoint',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold))
                : Text('Reaching Checkpoint')
                : Text('Reaching Checkpoint',
                style: TextStyle(
                  color: Colors.grey,
                )),
            onPressed: () {
              if (disableAll == false) {
                showToast("Please Wait");
                _getCurrentLocation().then((value) {
                  if (value) setAction("RCHECKPOINT");
                });
              }
              cancelActionSheet(context);
            },
          ),
          CupertinoActionSheetAction(
            child: disableAll == false
                ? nextAction == "LCHECKPOINT"
                ? Text('Leaving Checkpoint',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold))
                : Text('Leaving Checkpoint')
                : Text('Leaving Checkpoint',
                style: TextStyle(
                  color: Colors.grey,
                )),
            onPressed: () {
              if (disableAll == false) {
                showToast("Please Wait..");
                _getCurrentLocation().then((value) {
                  if (value) setAction("LCHECKPOINT");
                });
              }
              cancelActionSheet(context);
            },
          ),
          CupertinoActionSheetAction(
            child: disableAll == false
                ? nextAction == "IN_OFF"
                ? Text(
              'At Office',
              style: TextStyle(color: Colors.green),
            )
                : Text('At Office')
                : Text('At Office',
                style: TextStyle(
                  color: Colors.grey,
                )),
            onPressed: () {
              if (disableAll == false) {
                showToast("Please Wait");
                _getCurrentLocation().then((value) {
                  if (value) {
                    _getDistance().then((disValue) {
                      if (disValue)
                        setAction("IN_OFF");
                      else
                        DialogClass.showMaterialDialog(
                            context,
                            "Please select this option when you are near your office",
                            0);
                    });
                  }
                });
              }
              cancelActionSheet(context);
            },
          ),
          CupertinoActionSheetAction(
            child: disableAll == false
                ? nextAction == "CHECKIN"
                ? Text('Check in',
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold))
                : Text('Check in')
                : Text('Check In',
                style: TextStyle(
                  color: Colors.grey,
                )),
            onPressed: () {
              if (disableAll == false) {
                showToast("Please Wait");
                _getCurrentLocation().then((value) {
                  if (value) setAction("CHECKIN");
                });
              }
              cancelActionSheet(context);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () {
            cancelActionSheet(context);
          },
        ));

    return act;
  }

  void cancelActionSheet(BuildContext context) {
    Navigator.pop(context);
  }

  buildColumnForMessages() {
    if (finalDesc) Text("data");

    return annsExist == true
        ? Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: anns["anns"].length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 20.0),
              child: SizedBox(
                height: 100,
                width: MediaQuery.of(context).size.width - 50,
                child: GestureDetector(
                  onLongPress: isAdmin == true
                      ? () {
                    showAlertDialog(context,
                        anns["anns"][index]["id"].toString());
                  }
                      : () {},
                  child: Card(
                    child: SingleChildScrollView(
                      child: ListTile(
                        title: Padding(
                          padding:
                          const EdgeInsets.fromLTRB(8, 10, 8, 10),
                          child: Center(
                              child: SizedBox(
                                child: Text(
                                  anns["anns"][index]["message"],
                                  style: TextStyle(fontSize: 16),
                                ),
                              )),
                        ),
                        subtitle: Center(
                            child: SizedBox(
                              height: 40,
                              child: Column(
                                children: [
                                  new Divider(
                                    color: Colors.black,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Posted by:",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        anns["anns"][index]["fname"] +
                                            " " +
                                            anns["anns"][index]["lname"] +
                                            "(${anns["anns"][index]["time"]})",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    )
        : Center(
      child: CircularProgressIndicator(
        backgroundColor: Colors.teal,
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget buildColumnForWfh() {
    return wfhUsers.length == 0
        ? Container()
        : Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Working From Home...",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: wfhUsers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      "${index + 1} . ${wfhUsers[index]['username']}",
                      style:
                      TextStyle(color: Colors.white, fontSize: 16)),
                );
              }),
        ],
      ),
    );
  }

  Column buildColumnForCards() {
    return Column(
      children: [
        sunday == true
            ? SizedBox(
          width: 300,
          child: Card(
            child: ListTile(
              subtitle: Text("No task today so enjoy your day!"),
              trailing: Icon(Icons.airport_shuttle, color: Colors.green),
              title: new Text("Happy Sunday!!"),
            ),
          ),
        )
            : Container(),
        sunday == true
            ? Text("")
            : disableAll == false
            ? cheat == false
            ? buildFirstCard()
            : SizedBox(
          width: 300,
          child: Card(
            child: ListTile(
              subtitle: Text("Your boss has been notified"),
              trailing: Icon(Icons.cancel, color: Colors.red),
              title: new Text("You have tried to cheat"),
            ),
          ),
        )
            : SizedBox(),
        sunday == true
            ? Text("")
            : disableAll == false
            ? cheat == false
            ? buildSecondCard()
            : SizedBox(
          child: SizedBox(
            width: 300,
            child: Card(
              child: ListTile(
                subtitle: Text("Your boss has been notified"),
                trailing: Icon(Icons.cancel, color: Colors.red),
                title: new Text("You have tried to cheat"),
              ),
            ),
          ),
        )
            : SizedBox(),
        sunday == true
            ? Text("")
            : disableAll == false
            ? cheat == false
            ? buildThirdCard()
            : SizedBox(
          child: SizedBox(
            width: 300,
            child: Card(
              child: ListTile(
                subtitle: Text("Your boss has been notified"),
                trailing: Icon(Icons.cancel, color: Colors.red),
                title: new Text("You have tried to cheat"),
              ),
            ),
          ),
        )
            : SizedBox(),
        disableAll == true
            ? SizedBox(
          height: 40,
        )
            : SizedBox(),
        sunday == true
            ? Text("")
            : disableAll == true
            ? SizedBox(
          width: 300,
          child: Card(
            child: ListTile(
              leading: Icon(Icons.cancel, color: Colors.red),
              title: new Text("You have marked yourself OFF today"),
            ),
          ),
        )
            : SizedBox(),
        disableAll == true
            ? SizedBox(
          height: 40,
        )
            : SizedBox(),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF52796F),
        actions: <Widget>[
          Text(version,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              )),
        ],
        leading: new Container(),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Keep ",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "Connected",
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }

  showTotalScore() {
    return Container(
        child: Column(
          children: <Widget>[
            Text(
              "You have " + _counter.toString() + " points",
              style: TextStyle(
                  fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ));
  }

  buildFirstCard() {
    bool showGoCard = false;
    bool showBeforeCard = false;
    final startTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 7, 30);
    final endTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 00);
    final currentTime = DateTime.now();

    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      showGoCard = true;
    } else if (currentTime.isBefore(startTime)) {
      showBeforeCard = true;
    }
    var buttonState = _bString.substring(0, 1);
    if (buttonState == "1") {
      return returnPressedCard();
    } else if (buttonState == "0") {
      if (showGoCard) {
        color1 = Colors.white;
        icon1 = null;
        return Card(
          elevation: 20,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            children: <Widget>[
              Container(
                color: color1,
                child: InkWell(
                  child: ListTile(
                    trailing: icon1,
                    leading: Icon(
                      Icons.alarm,
                      color: Colors.teal,
                    ),
                    title: Text(
                      "Good Morning!!",
                      style: TextStyle(
                          color: Colors.teal,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    setState(() {
                      _getCurrentLocation().then((value) =>
                          saveButtonClicks("SAVE_CLICK1")
                              .then((value) => setColors1(value)));
                    });
                  },
                ),
              ),
            ],
          ),
        );
      } else if (showBeforeCard) {
        return Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: ListTile(
                  subtitle: Text(
                    "Too Soon!! Come back later",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(
                    Icons.alarm,
                    color: Colors.grey,
                  ),
                  title: Text(
                    "Good Morning!!",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      } else
        return Card(
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.grey,
                child: ListTile(
                  subtitle: Text(
                    "Too Late!! Come back tomorrow",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(
                    Icons.alarm,
                    color: Colors.white,
                  ),
                  trailing: Icon(
                    Icons.warning,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Good Morning!!",
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.lineThrough),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  buildSecondCard() {
    bool showGoCard = false;
    bool showBeforeCard = false;
    final startTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 30);
    final endTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 00);

    final currentTime = DateTime.now();

    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      showGoCard = true;
    } else if (currentTime.isBefore(startTime)) {
      showBeforeCard = true;
    }

    var fff = _bString.substring(1, 2);

    if (fff == "1") {
      return Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.green.shade300,
              child: InkWell(
                child: ListTile(
                  trailing: Icon(
                    Icons.check,
                    color: Colors.black,
                  ),
                  leading: Icon(
                    Icons.note,
                    color: Colors.black,
                  ),
                  title: Text(
                    "I have a plan for the day",
                    style: TextStyle(
                        color: fontColor,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (fff == "0") {
      color = Colors.white;
      iconCheck = null;
      if (showGoCard) {
        return Card(
          elevation: 20,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            children: <Widget>[
              Container(
                color: color,
                child: InkWell(
                  child: ListTile(
                    trailing: iconCheck,
                    leading: Icon(
                      Icons.note,
                      color: Colors.teal,
                    ),
                    title: Text(
                      "I have a plan for the day",
                      style: TextStyle(
                          color: Colors.teal,
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    TimeOfDay now = TimeOfDay.now();
                    setState(() {
                      _getCurrentLocation().then((value) =>
                          saveButtonClicks("SAVE_CLICK2")
                              .then((value) => setColors2(value)));
                    });
                  },
                ),
              ),
            ],
          ),
        );
      } else if (showBeforeCard) {
        return Card(
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: ListTile(
                  subtitle: Text(
                    "Too Soon!! Come back later",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(
                    Icons.note,
                    color: Colors.grey,
                  ),
                  title: Text(
                    "I have a plan for today",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      } else
        return Card(
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.grey,
                child: ListTile(
                  subtitle: Text(
                    "Too Late!! Come back tomorrow",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(
                    Icons.note,
                    color: Colors.white,
                  ),
                  trailing: Icon(
                    Icons.warning,
                    color: Colors.white,
                  ),
                  title: Text(
                    "I have a plan for the day",
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.lineThrough),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  buildThirdCard() {
    bool showGoCard = false;
    bool showBeforeCard = false;
    final startTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 15);
    final endTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 00);

    final currentTime = DateTime.now();

    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      showGoCard = true;
    } else if (currentTime.isBefore(startTime)) {
      showBeforeCard = true;
    }

    var buttonState = _bString.substring(2);
    if (buttonState == "1") {
      return Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.green.shade300,
              child: InkWell(
                child: ListTile(
                  trailing: Icon(
                    Icons.check,
                    color: Colors.black,
                  ),
                  leading: Icon(
                    Icons.note,
                    color: Colors.black,
                  ),
                  title: Text(
                    "On My Way ",
                    style: TextStyle(
                        color: fontColor,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (buttonState == "0") {
      if (showGoCard) {
        //if (now.hour > 0) {
        return Card(
          elevation: 20,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Container(
            color: color3,
            child: Column(
              children: <Widget>[
                InkWell(
                  child: ListTile(
                    trailing: icon3,
                    leading: Icon(Icons.traffic, color: Colors.black),
                    title: Text("On My Way",
                        style: TextStyle(color: fontColor, fontSize: 17)),
                  ),
                  splashColor: Colors.blue.withAlpha(30),
                  /* onTap: () {

                },  */
                ),
                ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      color: Color(0xFF9E9E9E),
                      child: const Text(
                        'On Time',
                        style: TextStyle(color: Colors.lightGreenAccent),
                      ),
                      onPressed: () {
                        TimeOfDay now = TimeOfDay.now();
                        setState(() {
                          _getCurrentLocation().then((value) =>
                              saveButtonClicks("SAVE_CLICK3a")
                                  .then((value) => setColors3(value)));
                        });
                      },
                    ),
                    FlatButton(
                      color: Color(0xFF9E9E9E),
                      child: const Text('Little Late',
                          style: TextStyle(color: Colors.orangeAccent)),
                      onPressed: () {
                        TimeOfDay now = TimeOfDay.now();
                        setState(() {
                          _getCurrentLocation().then((value) =>
                              saveButtonClicks("SAVE_CLICK3b")
                                  .then((value) => setColors3(value)));
                        });
                      },
                    ),
                    FlatButton(
                      color: Color(0xFF9E9E9E),
                      child: const Text('Very Late',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        TimeOfDay now = TimeOfDay.now();
                        setState(() {
                          _getCurrentLocation().then((value) =>
                              saveButtonClicks("SAVE_CLICK3c")
                                  .then((value) => setColors3(value)));
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      } else if (showBeforeCard) {
        return Card(
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: ListTile(
                  subtitle: Text(
                    "Too Soon!! Come back later",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  leading: Icon(
                    Icons.traffic,
                    color: Colors.grey,
                  ),
                  title: Text(
                    "On My Way",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      } else
        return Card(
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.grey,
                child: ListTile(
                  subtitle: Text(
                    "Too Late!! Come back tomorrow",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: Icon(
                    Icons.traffic,
                    color: Colors.white,
                  ),
                  trailing: Icon(
                    Icons.warning,
                    color: Colors.white,
                  ),
                  title: Text(
                    "On My Way (On-time)",
                    style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.lineThrough),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  setColors1(String val) {
    if (val == "1") {
      color1 = Colors.green.shade300;
      fontColor = Colors.black;
      icon1 = new Icon(
        Icons.check,
        color: Colors.black,
      );
      _bString = "100";
      _incrementCounter();
    }
  }

  setColors2(String val) {
    if (val == "1") {
      color = Colors.green.shade300;
      fontColor = Colors.black;
      iconCheck = new Icon(
        Icons.check,
        color: Colors.black,
      );
      _bString = replaceCharAt(_bString, 1, "1");
      _incrementCounter();
    }
  }

  setColors3(String val) {
    if (val == "1") {
      color3 = Colors.amber;
      fontColor = Colors.black;
      icon3 = new Icon(
        Icons.check,
        color: Colors.red,
      );
      _bString = replaceCharAt(_bString, 2, "1");
      _incrementCounter();
    }
  }

  String replaceCharAt(String oldString, int index, String newChar) {
    return oldString.substring(0, index) +
        newChar +
        oldString.substring(index + 1);
  }

  clearPref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(formattedDate);
    _bString = "000";
  }

  Future<String> setAction(String action) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _address = (prefs.getString("address") ?? "000");
    String _coords = (prefs.getString("coords") ?? "000");
    int id = int.tryParse((prefs.getString("userid") ?? "0"));
    var map = Map<String, dynamic>();
    // ignore: non_constant_identifier_names
    String SETACT = action;
    map['action'] = SETACT;
    map['id'] = id.toString();
    map['address'] = _address;
    map['notes'] = "";
    map['coords'] = _coords;
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
      setActionData = json.decode(response.body);
      if (setActionData["result"] != 0)
        var a = 1;
      else
        showToast("Error Please try again");
      if (action == "CHECKIN") {
        if (setActionData["result"] == 1) {
          nextAction = "LCHECKPOINT";
          DialogClass.showMaterialDialog(
              context, "Check-In Successful. Have a good day!", 1);
        } else if (setActionData["result"] == 2) {
          if (!isAutoCheckOut)
            DialogClass.showMaterialDialog(
                context, "You already have one check-in for today.", 0);
        }
      } else if (action == "WORKFROMHOME") {
        if (setActionData["result"] == 1) {
          nextAction = "REMOVE_WFH";
          DialogClass.showMaterialDialog(context, "WFH has been started.", 1);
        } else if (setActionData["result"] == 2) {
          if (!isAutoCheckOut)
            DialogClass.showMaterialDialog(
                context, "You already have one WFH for today.", 0);
        }
      } else if (action == "REMOVE_WFH") {
        if (setActionData["code"] == 1) {
          nextAction = "CHECKIN";
          DialogClass.showMaterialDialog(context, "WFH has been ended.", 1);
        } else if (setActionData["result"] == 2) {
          if (!isAutoCheckOut)
            DialogClass.showMaterialDialog(
                context, "You have already ended WFH for today.", 0);
        }
      } else if (action == "LUNCHSTART") {
        if (setActionData["result"] == 1) {
          nextAction = "IN_OFF";
          DialogClass.showMaterialDialog(context, "Lunch break started", 1);
        } else if (setActionData["result"] == 2) {
          if (!isAutoCheckOut)
            DialogClass.showMaterialDialog(context, "Lunch break stopped", 0);
        }
      } else if (action == "CHECKOUT") {
        if (setActionData["result"] == 1) {
          DialogClass.showMaterialDialog(
              context, "Check-Out Successful. See you soon!", 1);
          nextAction = "CHECKIN";
        } else if (setActionData["result"] == 2)
          DialogClass.showMaterialDialog(
              context, "You have to check-In for today", 0);
        else if (setActionData["result"] == 3 && !isCheckedOut) {
          DialogClass.showMaterialDialog(
              context, "You have checked out for today", 0);
          isCheckedOut = true;
        }
      } else if (action == "LCHECKPOINT") {
        if (setActionData["result"] == 1) {
          nextAction = "RCHECKPOINT";
          DialogClass.showMaterialDialog(
              context, "Added a new Leaving checkpoint", 1);
        } else if (setActionData["result"] == 2)
          DialogClass.showMaterialDialog(
              context, "You have to check-In for today", 0);
        else if (setActionData["result"] == 3)
          DialogClass.showMaterialDialog(
              context, "You have checked out for today", 0);
      } else if (action == "RCHECKPOINT") {
        if (setActionData["result"] == 1) {
          DialogClass.showMaterialDialog(
              context, "Added a new Reached checkpoint", 1);
          nextAction = "LCHECKPOINT";
        } else if (setActionData["result"] == 2)
          DialogClass.showMaterialDialog(
              context, "You have to check-In for today", 0);
        else if (setActionData["result"] == 3)
          DialogClass.showMaterialDialog(
              context, "You have checked out for today", 0);
      } else if (action == "LUNCHSTART") {
        if (setActionData["result"] == 1)
          DialogClass.showMaterialDialog(
              context, "Logged your start of Lunch", 1);
        else if (setActionData["result"] == 2)
          DialogClass.showMaterialDialog(
              context, "You have to check-In for today", 0);
        else if (setActionData["result"] == 3)
          DialogClass.showMaterialDialog(
              context, "You already have logged your lunch today", 0);
      } else if (action == "LUNCHEND") {
        if (setActionData["result"] == 1)
          DialogClass.showMaterialDialog(
              context, "Logged your end of Lunch", 1);
        else if (setActionData["result"] == 2)
          DialogClass.showMaterialDialog(
              context, "You have to check-In for today", 0);
        else if (setActionData["result"] == 3)
          DialogClass.showMaterialDialog(
              context, "You have to log in your start of Lunch", 0);
        else if (setActionData["result"] == 4)
          DialogClass.showMaterialDialog(
              context, "You have already logged your end of Lunch", 0);
      } else if (action == "SET_OFF") {
        DialogClass.showMaterialDialog(
            context, "Marked you off today. Thank you", 1);
        disableAll = true;
      } else if (action == "IN_OFF") {
        if (setActionData["result"] == 1) {
          nextAction = "LCHECKPOINT";
          DialogClass.showMaterialDialog(context, "Marked you at office", 1);
        } else if (setActionData["result"] == 2)
          DialogClass.showMaterialDialog(
              context, "You have to check-In for today", 0);
        else if (setActionData["result"] == 3)
          DialogClass.showMaterialDialog(
              context, "You have checked out for today", 0);
      }
      dtnow = DateTime.now();
      formattedDate = DateFormat('yyyy-MM-ddb').format(dtnow);
      prefs.setString("nextAction_" + formattedDate, nextAction);
    });
    return "Success!";
  }

  showAlertDialog(BuildContext context, String index) {
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Yes, Delete"),
      onPressed: () {
        deleteAnns(index).then((value) => Navigator.pop(context));
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Keep Connected"),
      content: Text("Would you like to delete this annoucement?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showSimpleAlertDialog(BuildContext context, String message, String title) {
    Widget continueButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _checkIfTimePassed() {
    final endTime = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 05);
    final currentTime = DateTime.now();
    setState(() {
      showExtension = false;
      if (currentTime.isAfter(endTime))
        expireCards = true;
      else
        expireCards = false;
    });
  }

  Future isStillOff() async {
    var map = Map<String, dynamic>();
    const _GET_SCORE_ = 'OFF_STATUS';
    map['action'] = _GET_SCORE_;
    map['id'] = userID.toString();

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
    print(response.body);
    this.setState(() {
      var data2 = json.decode(response.body);
      if (data2["result"] == 0) {
        disableAll = false;
      } else
        disableAll = true;

      DateTime dtnow = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(dtnow);

      if (formattedDate == data2["today"])
        cheat = false;
      else
        cheat = true;
    });
  }

  Future getScore() async {
    var map = Map<String, dynamic>();
    const _GET_SCORE_ = 'GET_SCORE';
    map['action'] = _GET_SCORE_;
    map['id'] = userID.toString();
    var jsonResponse;
    var response;
    var client = http.Client();
    try {
      response = await http.post(
          "https://www.keepconnected.duckdns.org/task/index.php",
          body: map);

      if (response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        if (jsonResponse != null) {
          setState(() {
            _counter = int.tryParse(jsonResponse['points'].toString()) ?? 0;
          });
        }
      }
    } finally {
      client.close();
    }
  }

  List wfhUsers = List.empty(growable: true);

  checkWorkFromHomeUsers(int id) async {
    var map = Map<String, dynamic>();
    const GET_WFH_USERS = 'GET_WORKFROMHOME';
    map['action'] = GET_WFH_USERS;
    map['userid'] = id.toString();
    map['company'] = company;
    print(map);
    var jsonResponse;
    Response response;
    var client = http.Client();
    try {
      response = await http.post(
          "https://www.keepconnected.duckdns.org/task/index.php",
          body: map);
    } finally {
      client.close();
    }
    if (response.statusCode == 200) jsonResponse = response.body;
    print((jsonDecode(jsonResponse)["payload"]));
    wfhUsers = jsonDecode(jsonResponse)["payload"];
  }

  removeFromWFHList(String name) async {
    var map = Map<String, dynamic>();
    const REMOVE_WFH = 'REMOVE_WFH';
    map['action'] = REMOVE_WFH;
    map['user'] = name;
    map['company'] = company;
    print(map);
    var jsonResponse;
    Response response;
    var client = http.Client();
    try {
      response = await http.post(
          "https://www.keepconnected.duckdns.org/task/index.php",
          body: map);
    } finally {
      client.close();
    }
    if (response.statusCode == 200) jsonResponse = response.body;
    print(jsonResponse);
  }

  Future getAnnouncements() async {
    annsExist = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = int.tryParse((prefs.getString("userid") ?? "0"));

    checkWorkFromHomeUsers(id);
    var map = Map<String, dynamic>();
    const _GET_FNAME_ = 'GET_MESSAGE';
    map['action'] = _GET_FNAME_;
    map['id'] = id.toString();
    map['company'] = company;

    var jsonResponse;
    var response;
    var client = http.Client();
    try {
      response = await http.post(
          "https://www.keepconnected.duckdns.org/task/index.php",
          body: map);
    } finally {
      client.close();
    }

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          anns = json.decode(response.body);
          annsExist = true;
        });
      }
    }
  }

  getFname() async {
    sharedPreferences.setString("superAdmin", "0");
    logo =
    "https://cdn3.iconfinder.com/data/icons/UltimateGnome/256x256/emblems/emblem-generic.png";
    finalDesc = false;
    descApproved = 2;
    globals.isAdminOnApp = false;
    isAdmin = false;
    isSuperAdmin = false;
    var map = Map<String, dynamic>();
    const _GET_FNAME_ = 'GET_FNAME';
    map['action'] = _GET_FNAME_;
    map['id'] = userID.toString();
    map['version'] = version;
    var jsonResponse;
    var response;
    var client = http.Client();

    try {
      response = await http.post(
          "https://www.keepconnected.duckdns.org/task/index.php",
          body: map);
    } finally {
      client.close();
    }

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (jsonResponse != null) {
        setState(() {
          finalDesc =
          jsonResponse['finalDesc'].toString() == "1" ? true : false;

          if (jsonResponse['desc'].toString() == "ok") {
            finalDesc = true;
            descApproved = 1;
          }
          if (jsonResponse['desc'].toString() == "nok") {
            finalDesc = false;
            descApproved = 0;
          }
          lastAction = jsonResponse['lastAction'].toString();
          fname = jsonResponse['fname'].toString();
          sharedPreferences.setString("username", fname);
          sharedPreferences.setString(
              "company", jsonResponse["company"].toString());
          sharedPreferences.setString(
              "companyName", jsonResponse["companyName"].toString());
          sharedPreferences.setString("logo", jsonResponse["logo"].toString());

          cName = jsonResponse["companyName"].toString();
          logo = "https://www.keepconnected.duckdns.org/task/" +
              jsonResponse["logo"].toString();

          if (jsonResponse['type'].toString() == "admin") {
            isAdmin = true;
            globals.isAdminOnApp = true;
          }
          if (jsonResponse['attribute'].toString() == "superadmin") {
            sharedPreferences.setString("superAdmin", "1");
            isSuperAdmin = true;
          }
          isLoaded = true;
        });
      }
    }
  }

  Future<void> deleteAnns(String index) async {
    var map = Map<String, dynamic>();
    const _GET_FNAME_ = 'DEL_ANNS';
    map['action'] = _GET_FNAME_;
    map['id'] = userID.toString();
    map['annsID'] = index.toString();
    var jsonResponse;
    var response;
    var client = http.Client();
    try {
      response = await http.post(
          "https://www.keepconnected.duckdns.org/task/index.php",
          body: map);
    } finally {
      client.close();
    }

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          getAnnouncements();
        });
      }
    }
  }

  // ignore: missing_return
  Future<String> saveButtonClicks(String action) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _address = (prefs.getString("address") ?? "000");
    showToast("Please Wait...");
    var map = Map<String, dynamic>();
    var currentAction = action;
    map['action'] = currentAction;
    map['id'] = userID.toString();
    map['address'] = _address;
    print(map);

    var jsonResponse;
    String value;
    value = "0";
    var response;
    var client = http.Client();

    try {
      response = await http.post(
          "https://www.keepconnected.duckdns.org/task/index.php",
          body: map);
    } finally {
      client.close();
    }

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (jsonResponse != null) {
        setState(() {
          value = jsonResponse['result'].toString();
          if (value == "1") {
            showToast("Great. Good Job!!");
            _controllerCenter.play();
          } else {
            showToast("Sorry! Error Occured. Please try again");
            _controllerCenter.stop();
            setState(() {
              value = "0";
            });
          }
        });
      }
    } else {
      setState(() {
        value = "0";
      });
    }
    return value;
  }

  // ignore: missing_return
  Future<String> saveDevToken(String token) async {
    var map = Map<String, dynamic>();
    map['action'] = "SAVE_TOKEN";
    map['id'] = userID.toString();
    map['devToken'] = token;
    String value;

    var jsonResponse;
    var client = http.Client();
    var response;

    try {
      value = "0";
      response = await client.post(
          "https://www.keepconnected.duckdns.org/task/index.php",
          body: map);
    } finally {
      client.close();
    }

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);

      if (jsonResponse != null) {
        setState(() {
          value = jsonResponse['result'].toString();
        });
      }
    } else {
      setState(() {
        value = "0";
      });
    }
    return value;
  }
}
