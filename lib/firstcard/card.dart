import 'package:flutter/material.dart';

returnPressedCard() {
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
                Icons.alarm,
                color: Colors.black,
              ),
              title: Text(
                "Good Morning!!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

returnReadyCard() {

}
