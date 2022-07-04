import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DistanceHistory extends StatefulWidget {

  @override
  _DistanceHistoryState createState() => _DistanceHistoryState();
}

class _DistanceHistoryState extends State<DistanceHistory> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color(0xFF52796F),
      appBar: new AppBar(
        title: new Text(
          "Distance - " + "name",
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
                // getData();
              })
        ],
      ),
      body:
      // _progressBarActive == true
      //     ? Center(
      //   child: CircularProgressIndicator(
      //     backgroundColor: Colors.teal,
      //     valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
      //   ),
      // )
      //     :
      Column(
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
                        // String thisMonth = currentMonth;
                        // if (int.parse(thisMonth) > 1) {
                        //   int valThisMonth = int.parse(thisMonth) - 1;
                        //   currentMonth =
                        //       valThisMonth.toString().padLeft(2, "0");
                        // }
                        // this.getData();
                      });
                    },
                    child: Text(
                      "< Prev",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  Text("thisMonth",
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
                        // String thisMonth = currentMonth;
                        // if (int.parse(thisMonth) >= 1) {
                        //   int valThisMonth = int.parse(thisMonth) + 1;
                        //   currentMonth =
                        //       valThisMonth.toString().padLeft(2, "0");
                        // }
                        // this.getData();
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
            label: Text("Total Distance: 200KM",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          ),
          Container(
            child: Expanded(
              child:
              // data == null
              //     ? Column(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Center(
              //       child: Text(
              //         "No data for the user right now",
              //         style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 20,
              //             fontWeight: FontWeight.bold),
              //       ),
              //     ),
              //   ],
              // )
              //     :

              ListView.builder(
                itemCount:4,
                // data == null ? 0 : data['payload'].length,
                itemBuilder: (BuildContext context, int index) {
                  return
                    // formattedDate.toString().substring(0, 4) !=
                    //   data['payload'][index]['date']
                    //       .toString()
                    //       .substring(0, 4)
                    //   ? Container()
                    //   :

                    Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(
                          vertical: 5, horizontal: 25),
                      color: Colors.white,
                      child: ListTile(
                          onLongPress: () {},
                          onTap: () {
                            // Navigator.of(context).push(
                            //     _createRoute(
                            //         int.tryParse(
                            //             data['payload'][index]
                            //             ["userid"]),
                            //         adminId,
                            //         data['payload'][index]
                            //         ["date"]));
                          },
                          title: Text(
                             "date",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          trailing: Text(
                            "Distance"
                                ,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                CupertinoColors.activeBlue,
                                fontSize: 19),
                          )));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
