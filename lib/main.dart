import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;


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
  int _counter = 0;
  String text = "";
  Map<String, int> beacons = new Map();



  List<String> deviceData = new List<String>();
  List<String> deviceData2 = new List<String>();
  Map<String, int> deviceMap = new Map();
  FlutterBlue flutterBlue = FlutterBlue.instance;

  _MyHomePageState() {
    flutterBlue.scan().listen(this.bluetoothscan);


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

  double distance(int rssi, int p){
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
        double dist = 0.0;

        data.sublist(1,9).forEach((int f) {id += f.toRadixString(16).padLeft(2, "0");});

        if(!deviceMap.containsKey(id)) {
          deviceMap[id] = deviceData.length;
          deviceData.add("");
        }
        var dindex = deviceMap[id];
        setState(() {

          if(!beacons.containsKey(id))
          {

            String beaconGet ="http://omaraa.ddns.net:62027/beacons/" + id;
            debugPrint(beaconGet);
            final response = http.get(
              beaconGet,
              headers: {"Accept": "application/json"},
            );

            response.then((res) {
              Map<String, dynamic> result = jsonDecode(res.body);
              if (res.statusCode == 200) {
                int offs = int.parse(result['shovid']);
                debugPrint(offs.toString());
                beacons[id] = offs;
                debugPrint(beacons.length.toString());
              }
            });

          }

          else {
            dist = distance(scanResult.rssi, beacons[id]);
            debugPrint("Distance is: " + dist.toString());
            deviceData[dindex] =
                id + " " + scanResult.rssi.toString() + " " +
                    new DateTime.now().millisecondsSinceEpoch.toString() + " " +
                    dist.toString();
          }
        });
      }
    }
  }



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
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            DeviceWidget(deviceData[index]),
        itemCount: deviceData.length,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {deviceData.clear(); deviceMap.clear();},
        child: Icon(Icons.add),
      ),
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