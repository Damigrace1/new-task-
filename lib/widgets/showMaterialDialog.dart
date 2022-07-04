import 'package:flutter/material.dart';

class DialogClass{
  DialogClass._();

  static showMaterialDialog(BuildContext context, String message, int res) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: res == 1
                  ? Text("Success", style: TextStyle(color: Colors.white))
                  : Text("Error", style: TextStyle(color: Colors.white)),
              backgroundColor: res == 1 ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: EdgeInsets.only(top: 10.0),
              content: Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),
                        Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: new Text(message,
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.white)),
                            ) //
                        ),
                        SizedBox(
                          height: 20.0,
                          width: 5.0,
                        ),
                        Divider(
                          color: Colors.grey,
                          height: 4.0,
                        ),
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(32.0),
                                  bottomRight: Radius.circular(32.0)),
                            ),
                            child: Text(
                              "OK",
                              style:
                              TextStyle(color: Colors.blue, fontSize: 25.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ));
        });
  }

}