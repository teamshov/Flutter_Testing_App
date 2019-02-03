import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;
import './Coordinate.dart';
import './CustomDialog.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {



  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {



    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = "";
  String text2 = "Initialized";
  Map<String, Map<String, dynamic>> beacons = new Map();
  Map<String, double> tempBeacons = new Map();


  List<String> deviceData = new List<String>();
  List<String> deviceData2 = new List<String>();
  Map<String, int> deviceMap = new Map();
  FlutterBlue flutterBlue = FlutterBlue.instance;

  _MyHomePageState() {
    flutterBlue.scan(scanMode: ScanMode.lowLatency).listen(this.bluetoothscan);


    var duration = Duration(seconds: 10);
    Timer.periodic(duration, this.timeoutchecker);

  }

  void timeoutchecker(Timer timer) {

    deviceMap.forEach((id, index) async {
      if(deviceData2.length <= index) return;
      if(deviceData[index].compareTo(deviceData2[index]) == 0) {
        deviceData[index] = "Timeout";
      }
    });

    deviceData2 = new List.from(deviceData);
  }

  double distance(int rssi, double p){
    double dist = 0.0;
    dist = pow(10, ((p-rssi)/20));
    return dist;
  }

  Coordinate compare(Coordinate b1, Coordinate b2, Coordinate one, Coordinate two)
  {
    double one_b1 = sqrt((one.x*one.x - b1.x*b1.x)+(one.y*one.y - b1.y*b1.y));
    double one_b2 = sqrt((one.x*one.x - b2.x*b2.x)+(one.y*one.y - b2.y*b2.y));

    double two_b1 = sqrt((two.x*two.x - b1.x*b1.x)+(two.y*two.y - b1.y*b1.y));
    double two_b2 = sqrt((two.x*two.x - b2.x*b2.x)+(two.y*two.y - b2.y*b2.y));

    one_b1 = (one_b1-b1.r).abs();
    one_b2 = (one_b2-b2.r).abs();

    two_b1 = (two_b1-b1.r).abs();
    two_b2 = (two_b2-b2.r).abs();

    if((one_b1+one_b2)>(two_b1+two_b2))
      return two;
    else
      return one;
  }

  void location() {
    if (beacons.length < 3) {
      text2 = "Not enough beacons";
      debugPrint(text2);

      return;
    }

    var v = beacons.values;
    var beacon1 = v.elementAt(0);
    var beacon2 = v.elementAt(1);
    var beacon3 = v.elementAt(2);
    Coordinate b1 = new Coordinate(
        (beacon1['xpos'] * 1.0), (beacon1['ypos'] * 1.0),
        (beacon1['distance'] * 1.0));
    Coordinate b2 = new Coordinate(
        (beacon2['xpos'] * 1.0), (beacon2['ypos'] * 1.0),
        (beacon2['distance'] * 1.0));
    Coordinate b3 = new Coordinate(
        (beacon3['xpos'] * 1.0), (beacon3['ypos'] * 1.0),
        (beacon3['distance'] * 1.0));

    double m = (b1.x - b2.x) / (b2.y - b1.y);
    double c = ((b2.r * b2.r) - (b2.x * b2.x) - (b2.y * b2.y) - (b1.r * b1.r) +
        (b1.x * b1.x) + (b1.y * b1.y)) / (2 * (b1.y - b2.y));

    double k = c - b3.y;

    double a = m * m;
    double b = (1 - (2 * b3.x) - (2 * m * k));
    double C = ((k * k) + (b3.x * b3.x) - (b3.r * b3.r));

    double D = b * b - 4 * a * C;
    if (D < 0) {
      text2 = "Imaginary roots";
      debugPrint(text2);

      return;
    }

    double xloc1 = (-1 * b - sqrt(D)) / (2 * a);
    double xloc2 = (-1 * b + sqrt(D)) / (2 * a);

    double yloc1 = m * xloc1 + c;
    double yloc2 = m * xloc2 + c;

    Coordinate one = new Coordinate(xloc1, yloc1, 0);
    Coordinate two = new Coordinate(xloc2, yloc2, 0);

    Coordinate closest = compare(b1, b2, one, two);
    text2 =
        "Coordinates are " + closest.x.toString() + ", " + closest.y.toString();
    debugPrint(text2);
  }

  void bluetoothscan(scanResult) async {
    var servicedata = scanResult.advertisementData.serviceData;
    if(servicedata.length > 0) {
      var data = servicedata.entries.toList().elementAt(0).value;
      if(data.isNotEmpty && (data.elementAt(0) & 0x0F == 0x02)) {
        debugPrint(data.toString());
        var id = "";

        data.sublist(1,9).forEach((int f) {id += f.toRadixString(16).padLeft(2, "0");});

        if(!deviceMap.containsKey(id)) {
          deviceMap[id] = deviceData.length;
          deviceData.add("");
        }
        var dindex = deviceMap[id];
        setState(() {

          if(!beacons.containsKey(id))
          {

            String beaconGet ="http://omaraa.ddns.net:62027/db/beacons/" + id;
//            debugPrint(beaconGet);
            final response = http.get(
              beaconGet,
              headers: {"Accept": "application/json"},
            );

            response.then((res) {
              Map<String, dynamic> result = jsonDecode(res.body);
              if (res.statusCode == 200) {
//                double offs = (result['offset'])*1.0;
//                debugPrint(offs.toString());
                beacons[id] = result;
                tempBeacons[id] = 0.0;
                result['distance'] = 0.0;
              }
            });

          }

          else {
            var tbeacon = tempBeacons[id];
            if (tbeacon == 0.0) {
              tempBeacons[id] = distance(scanResult.rssi, beacons[id]['offset']*1.0);
              return;
            }
            else {
              var beacon = beacons[id];
              beacon['distance'] = (distance(scanResult.rssi, beacon['offset']*1.0) + tempBeacons[id])/2.0;
              debugPrint("Distance to " + id.toString() + " is " + beacon['distance'].toString());
              deviceData[dindex] =
                  id + " " + scanResult.rssi.toString() + " " +
                      new DateTime.now().millisecondsSinceEpoch.toString() + " " +
                      beacon['distance'].toString();
              tempBeacons[id] = 0.0;
            }

          }

        });
      }
    }
  }


  CustomDialog dialog = new CustomDialog();
  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  location();
                  dialog.information(context, "Coordinate Calculation", text2);
                },
                  child: Text('Get Location'),

              )
            ],
          ),
//          Row (
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              new Expanded (
//                child: ListView.builder(
//                  itemBuilder: (BuildContext context, int index) =>
//                      DeviceWidget(deviceData[index]),
//                  itemCount: deviceData.length,
//                ),
//              )
//            ],
//          )
        ],
      )

    );
  }
}


class DeviceWidget extends StatelessWidget {

  String text;

  DeviceWidget(String t) {
    text = t;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(text);
  }


}