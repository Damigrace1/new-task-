// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
//
// void main() {
//   //int indexid;
//   runApp(new Container(child: Extendwork()));
// }
//
// class Extendwork extends StatefulWidget {
//   Extendwork({Key key}) : super(key: key);
//
//   @override
//   _ExtendworkState createState() => _ExtendworkState();
// }
//
// class _ExtendworkState extends State<Extendwork> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF52796F),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xFF52796F),
//         title: Text("Checkout Reminder"),
//       ),
//       body: SafeArea(
//           child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(0.0),
//             child: Image.asset("assets/images/3.gif"),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Text(
//             "What do you want to do ?",
//             style: TextStyle(color: Colors.white, fontSize: 19),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               new RaisedButton(
//                 color: Colors.redAccent,
//                 onPressed: () {
//                   setAction("CHECKOUT");
//
//                   //Navigator.pop(context);
//                 },
//                 child: new Text(
//                   "Checkout",
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//               new RaisedButton(
//                 color: Colors.greenAccent,
//                 onPressed: () {
//                   setAction("EXTEND");
//
//                   //Navigator.pop(context);
//                 },
//                 child: new Text("Keep Working"),
//               )
//             ],
//           ),
//         ],
//       )),
//     );
//   }
//
//   void showToast(String mesg) {
//     ToastGravity gravity = ToastGravity.CENTER;
//
//     Fluttertoast.showToast(
//         msg: mesg,
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: gravity,
//         backgroundColor: Colors.white,
//         textColor: Colors.black);
//   }
//
//   Future<String> setAction(String action) async {
//     //Scaffold.of(context).showSnackBar(SnackBar(
//     //  content: Text("Sending Message"),
//     // ));
//     //_getCurrentLocation().then((value) => print(value.toString()));
//
//     // if (serviceStatus) {
//     //_getCurrentLocation();
//     //showToast("Please Wait");
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String _address = (prefs.getString("address") ?? "000");
//     String _coords = (prefs.getString("coords") ?? "000");
//     int id = int.tryParse((prefs.getString("userid") ?? "0"));
//
//     var map = Map<String, dynamic>();
//     // ignore: non_constant_identifier_names
//     String SETACT = action;
//     map['action'] = SETACT;
//     map['id'] = id.toString();
//     map['address'] = _address;
//     map['notes'] = "";
//     map['coords'] = _coords;
//     map['company'] = 1;
//
//     var response;
//     var client = http.Client();
//     try {
//       response = await http.post(
//           Uri.encodeFull(
//               "https://www.keepconnected.duckdns.org/task/index.php"),
//           body: map,
//           headers: {"Accept": "application/json"});
//     } finally {
//       client.close();
//     }
//     this.setState(() {
//       var data2 = json.decode(response.body);
//
//       if (data2["result"] != 0)
//         var a = 1;
//       //showToast("Success!!");
//       else
//         showToast("Error Please try again");
//
//       //print(data2);
//       if (action == "CHECKOUT") {
//         if (data2["result"] == 1) {
//           _showMaterialDialog("Check-Out Successful. See you soon!", 1);
//           //nextAction = "CHECKIN";
//         } else if (data2["result"] == 2)
//           _showMaterialDialog("You have to check-In for today", 0);
//         else if (data2["result"] == 3)
//           _showMaterialDialog("You have checked out for today", 0);
//       }
//
//       DateTime dtnow = DateTime.now();
//       var formattedDate = DateFormat('yyyy-MM-ddb').format(dtnow);
//       //prefs.setString("nextAction_" + formattedDate, nextAction);
//
//       /*
//       else if (data2["result"] == 2)
//         _showMaterialDialog("Declined. Thank you");
//       else
//         _showMaterialDialog("Something went wrong. Please try again later"); */
//       //_showCupertinoDialog();
//     });
//
//     // _showToast(context);
//     return "Success!";
//     ////} else
//     // showToast("Turn On your location");
//   }
//
//   _showMaterialDialog(String message, int res) {
//     /*  showDialog(
//         context: context,
//         builder: (_) => new AlertDialog(
//               backgroundColor: res == 1 ? Colors.white : Colors.red[100],
//               title: new Text("Keep Connected"),
//               content: new Text(message),
//               actions: <Widget>[
//                 FlatButton(
//                   child: Text('Close'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 )
//               ],
//             )); */
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//               title: res == 1
//                   ? Text("Success", style: TextStyle(color: Colors.white))
//                   : Text("Error", style: TextStyle(color: Colors.white)),
//               backgroundColor: res == 1 ? Colors.green : Colors.red,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(32.0))),
//               contentPadding: EdgeInsets.only(top: 10.0),
//               content: Stack(
//                 children: <Widget>[
//                   Container(
//                     width: MediaQuery.of(context).size.width,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       mainAxisSize: MainAxisSize.min,
//                       children: <Widget>[
//                         SizedBox(
//                           height: 20.0,
//                         ),
//                         Center(
//                             child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: new Text(message,
//                               style: TextStyle(
//                                   fontSize: 20.0, color: Colors.white)),
//                         ) //
//                             ),
//                         SizedBox(
//                           height: 20.0,
//                           width: 5.0,
//                         ),
//                         Divider(
//                           color: Colors.grey,
//                           height: 4.0,
//                         ),
//                         InkWell(
//                           child: Container(
//                             padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.only(
//                                   bottomLeft: Radius.circular(32.0),
//                                   bottomRight: Radius.circular(32.0)),
//                             ),
//                             child: Text(
//                               "OK",
//                               style:
//                                   TextStyle(color: Colors.blue, fontSize: 25.0),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           onTap: () {
//                             Navigator.pop(context);
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   /*  Positioned(
//                     top: 0.0,
//                     right: 0.0,
//                     child: FloatingActionButton(
//                       child: Image.asset("assets/red_cross.png"),
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(80)),
//                       backgroundColor: Colors.white,
//                       mini: true,
//                       elevation: 5.0,
//                     ),
//                   ), */
//                 ],
//               ));
//         });
//     //Navigator.pop(context);
//   }
// }
