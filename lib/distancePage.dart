import 'distanceHistory.dart';
import 'package:flutter/material.dart';
import 'model/distance.dart';

class DistancePage extends StatefulWidget {
  final List<DistanceModel> data;
  final String month;
  const DistancePage({required this.data, required this.month});

  @override
  _DistancePageState createState() => _DistancePageState(this.data);
}

class _DistancePageState extends State<DistancePage> {
  final List<DistanceModel> data;
  _DistancePageState(this.data);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF52796F),
      appBar: new AppBar(
        title: new Text("Distance"),
        backgroundColor: const Color(0xFF52796F),
        elevation: 0,
      ),
      body: Column(
        children: [
          Center(
            child: Text(widget.month,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                      color: Colors.white,
                      child: ListTile(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>DistanceHistory()));
                        },
                        title: Text(data[index].name),trailing: Text(data[index].distance.toString()),),);
                }),
          ),
        ],
      ),
    );
  }
}
