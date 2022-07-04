import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isLoading = false;
  bool _sentOTP = false;
  var data;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      backgroundColor: const Color(0xFF52796F),
      body: Container(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                backgroundColor: Colors.teal,
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
              ))
            : ListView(
                children: <Widget>[
                  headerSection(),
                  SizedBox(height: 28,),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
    );
  }

  Container headerSection() {
    return Container(
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 50.0),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Text(
                "Keep Connected",
                style: TextStyle(
                    fontSize: 50,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            autofocus: _sentOTP == false ? true : false,
            keyboardType: TextInputType.phone,
            controller: emailController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            maxLength: 10,
            decoration: InputDecoration(
              icon: Icon(Icons.phone, color: Colors.white70),
              hintText: "Phone",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          _sentOTP==true?
          TextFormField(
                  autofocus: _sentOTP == true ? true : false,
                  keyboardType: TextInputType.number,
                  controller: passwordController,
                  cursorColor: Colors.white,
                  maxLength: 6,
                  style: TextStyle(color: Colors.white70),
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock, color: Colors.white70),
                    hintText: "OTP",
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70)),
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                ):Container(),
        ],
      ),
    );
  }

  Container buttonSection() {
    return Container(
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 30.0),
      child: RaisedButton(
        onPressed:
            () {
          _sentOTP == false
              ? setState(() {
                  _isLoading = true;
                  getOTP();
                })
              : setState(() {
                  _isLoading = true;
                  loginWithOTP();
                });
          },
        elevation: 3,
        color: _sentOTP == false ? Colors.blue : Colors.teal[50],
        child: _sentOTP == false
            ? Text("Request OTP", style: TextStyle(color: Colors.white70))
            : Text("Login", style: TextStyle(color: Colors.teal)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Future<String> getOTP() async {
    var map = Map<String, dynamic>();
    const _SEND_OTP_ = 'SEND_OTP';
    map['action'] = _SEND_OTP_;
    map['phone'] = "+91${emailController.text}";
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
    });
    _isLoading = false;
    _sentOTP = true;
    return "Success!";
  }

  Future<String> loginWithOTP() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var map = Map<String, dynamic>();
    const _LOGIN_ = 'LOGIN';
    map['action'] = _LOGIN_;
    map['phone'] = "+91${emailController.text}";
    map['otp'] = passwordController.text;
    var response;
    var client = http.Client();
    try {
      response = await http.post(
          Uri.parse("https://www.keepconnected.duckdns.org/task/index.php"),
          body: map,
          headers: {"Accept": "application/json"});
    } finally {
      client.close();
    }
    this.setState(() {
      data = json.decode(response.body);
    });
    if (data["userid"] != 0) {
      sharedPreferences.setString("userid", data["userid"].toString());
      sharedPreferences.setString("company", data["conpany"].toString());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else
      _showDialog();


    _isLoading = false;
    _sentOTP = true;
    return "Success!";
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Error"),
          content: new Text("Incorrect OTP"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
