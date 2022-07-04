import 'dart:async';
import 'dart:convert';
import 'main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Route _createRouteHomePage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
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

class MessagePost extends StatefulWidget {
  MessagePost({Key key}) : super(key: key);

  @override
  _MessagePostState createState() => _MessagePostState();
}

class _MessagePostState extends State<MessagePost> {
  var checkedValue = false;
  List<String> announcementList = List<String>.empty(growable: true);
  SharedPreferences prefs;

  initSavedList() async {
    prefs = await SharedPreferences.getInstance();

    announcementList = prefs.getStringList('announcements');
    if (announcementList == null)
      announcementList=[];
    setState(() {});
  }

  addAnnouncement() {
    announcementList.add(annController.text);
    prefs.setStringList('announcements', announcementList);
    setState(() {});
    annController.clear();
  }

  @override
  void initState() {
    initSavedList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF52796F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF52796F),
          elevation: 0,
          title: Text("Post a new announcement"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: <Widget>[
                Card(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: annController,
                        autofocus: true,
                        maxLines: 10,
                        decoration: InputDecoration.collapsed(
                            hintText: "Enter the announcement here"),
                      ),
                    )),
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
                        onPressed: () {
                          postAnnouncement();
                        },
                        child: const Text('Post',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                      RaisedButton(
                        color: const Color(0xFF1B4332),
                        padding: EdgeInsets.all(10),
                        splashColor: Colors.yellow[200],
                        elevation: 6,
                        onPressed: () {
                          addAnnouncement();
                        },
                        child: const Text('Save',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                      RaisedButton(
                        color: const Color(0xFF1B4332),
                        padding: EdgeInsets.all(10),
                        splashColor: Colors.yellow[200],
                        elevation: 6,
                        onPressed: () {},
                        child: const Text('Cancel',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ],
                  ),
                ),

                announcementList==null? Container(): ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: announcementList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(announcementList[index],
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                            PopupMenuButton(
                              icon:Icon(Icons.more_vert, color: Colors.white,),
                              itemBuilder: (context){
                              return [
                               PopupMenuItem(child: Text("Select"),value:1),
                                PopupMenuItem(child: Text("Delete"), value:2)
                              ];
                            }, onSelected: (value){
                              if(value==1)
                                annController.text = announcementList[index];
                              if(value==2){
                                announcementList.removeAt(index);
                                prefs.setStringList('announcements', announcementList);
                                setState(() {
                                });
                              }
                            },)
                          ],
                        ),
                      );
                    })
              ],
            ),
          ),
        ));
  }

  final TextEditingController annController = new TextEditingController();
  Future postAnnouncement() async {
    showToast("Please Wait...");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int company = int.tryParse((prefs.getString("company") ?? "0"));
    int userID = int.tryParse((prefs.getString("userid") ?? "0"));
    var map = Map<String, dynamic>();
    const _GET_SCORE_ = 'POST_MESSAGE';

    map['action'] = _GET_SCORE_;
    map['id'] = userID.toString();
    map['message'] = annController.text;
    map['company'] = company.toString();
    print("here in total Score $userID");


    var response;
    var client = http.Client();
    try {
      response = await http.post(
          Uri.encodeFull("https://www.keepconnected.duckdns.org/task/index.php"),
          body: map,
          headers: {"Accept": "application/json"});
    } finally {
      client.close();
    }
    this.setState(() {
      var data2 = json.decode(response.body);

      if (data2["result"] == 1) {
        _showMaterialDialog("Success: Announcement Posted");
        annController.text = "";
      } else
        _showMaterialDialog("Error: Announcement not Posted. Please try again later");
    });
  }

  void showToast(String mesg) {
    Fluttertoast.showToast(
        msg: mesg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.greenAccent,
        textColor: Colors.black);
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
                    Timer _timer = new Timer(const Duration(milliseconds: 100), () {
                      setState(() {
                        Navigator.of(context).push(_createRouteHomePage());
                      });
                    });
                  },
                )
              ],
        ));
  }
}
