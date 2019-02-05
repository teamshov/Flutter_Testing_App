import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;
import './Coordinate.dart';
import './CustomDialog.dart';
import './Grid.dart';
import 'package:spritewidget/spritewidget.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

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

  Grid g;
  NodeWithSize root;

  _MyHomePageState() {

  }

  @override
  void initState() {
    super.initState();

    flutterBlue.scan(scanMode: ScanMode.lowLatency).listen(this.bluetoothscan);

    var duration = Duration(seconds: 10);
    Timer.periodic(duration, this.timeoutchecker);

    root = new NodeWithSize(Size(100,100));
    g = new Grid(1, Size(31,40));
    root.addChild(g);

    g.setColor(0, 0, Color.fromARGB(100, 0, 255, 0));
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
            final response = http.get(
              beaconGet,
              headers: {"Accept": "application/json"},
            );
            response.then((res) {
              Map<String, dynamic> result = jsonDecode(res.body);
              if (res.statusCode == 200) {
                beacons[id] = result;
                tempBeacons[id] = 0.0;
                result['distance'] = 0.0;

              }
            });

          }

          else {


              var beacon = beacons[id];
              beacon['distance'] = (distance(scanResult.rssi, beacon['offset']*1.0));
              debugPrint("Distance to " + id.toString() + " is " + beacon['distance'].toString());
              deviceData[dindex] =
                  id + " " + scanResult.rssi.toString() + " " +
                      new DateTime.now().millisecondsSinceEpoch.toString() + " " +
                      beacon['distance'].toString();

          }

        });
      }
    }
  }


  CustomDialog dialog = new CustomDialog();
  @override
  Widget build(BuildContext context) {

    //return new SpriteWidget(rc);
      return Scaffold(
        appBar:


          AppBar(
            title: Text(widget.title),
          ),
          body: new Material(child:new SizedBox (
            width: 500,
            height: 500,
            child: new SpriteWidget(g)),
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