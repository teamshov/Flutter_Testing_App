import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

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
  List<String> deviceData = new List<String>();
  List<String> deviceData2 = new List<String>();
  Map<String, int> deviceMap = new Map();
  FlutterBlue flutterBlue = FlutterBlue.instance;

  _MyHomePageState() {
      flutterBlue.scan().listen(this.bluetoothscan);


      var duration = Duration(seconds: 8);
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

  void bluetoothscan(scanResult) async {
    var servicedata = scanResult.advertisementData.serviceData;
    if(servicedata.length > 0) {
      var data = servicedata.entries.toList().elementAt(0).value;
      if(data.isNotEmpty && (data.elementAt(0) & 0x0F == 0x02)) {
        debugPrint(data.toString());
        var id = "";
        await data.sublist(1,9).forEach((f) async {id += f.toRadixString(16);});

        if(!deviceMap.containsKey(id)) {
          deviceMap[id] = deviceData.length;
          deviceData.add("");
        }
        var dindex = deviceMap[id];
        setState(() {
          deviceData[dindex] = id + " " + scanResult.rssi.toString() + " " + new DateTime.now().millisecondsSinceEpoch.toString();
        });
      }
    }
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
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