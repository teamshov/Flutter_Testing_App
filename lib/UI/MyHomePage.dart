import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;
import '../Coordinate.dart';
import '../CustomDialog.dart';
import '../ProbabilityGrid.dart';
import 'package:spritewidget/spritewidget.dart';
import '../Beacon.dart';
import '../GridRendering.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text2 = "Initialized";

  Map<String, Beacon> monitoredBeacons = new Map<String, Beacon>();
  List<String> ignoredBeacons = new List<String>();

  FlutterBlue flutterBlue = FlutterBlue.instance;

  Grid g;
  ProbabilityGrid probabilityGrid;
  NodeWithSize root;

  _MyHomePageState();

  @override
  void initState() {
    super.initState();

    flutterBlue.scan(scanMode: ScanMode.lowLatency).listen(this.bluetoothscan);

    root = new NodeWithSize(Size(100, 100));
    g = new Grid(1, Size(31, 40));
    root.addChild(g);

    g.setColor(0, 0, Color.fromARGB(100, 0, 255, 0));
  }

  void updatePos() {
    while (true) {
      monitoredBeacons.forEach((String id, Beacon b) {
        if (b.checkIsWithinRange()) {
          probabilityGrid.setCircleProbabilty(b.x, b.y, b.distance, callback);
        }
      });
    }
  }

  void getPos() {
    GridPos gridPos = probabilityGrid.getHighestProbPos();
  }

  void bluetoothscan(scanResult) async {
    var servicedata = scanResult.advertisementData.serviceData;
    if (servicedata.length > 0) {
      var data = servicedata.entries.toList().elementAt(0).value;
      if (data.isNotEmpty && (data.elementAt(0) & 0x0F == 0x02)) {
        debugPrint(data.toString());
        var id = "";

        data.sublist(1, 9).forEach((int f) {
          id += f.toRadixString(16).padLeft(2, "0");
        });

        if (!monitoredBeacons.containsKey(id) || !ignoredBeacons.contains(id)) {
          monitoredBeacons[id] = new Beacon(id);
          monitoredBeacons[id].updateBeacon();
        }
        setState(() {
          if (monitoredBeacons[id].offset == 0) {
            String beaconGet = "http://omaraa.ddns.net:62027/db/beacons/" + id;
            final response = http.get(
              beaconGet,
              headers: {"Accept": "application/json"},
            );
            response.then((res) {
              Map<String, dynamic> result = jsonDecode(res.body);
              if (res.statusCode == 200) {
                monitoredBeacons[id].x = result['xpos'];
                monitoredBeacons[id].y = result['ypos'];
                monitoredBeacons[id].offset = result['offset'];
                monitoredBeacons[id].distance = monitoredBeacons[id].Distance();
                return;
              }
            });
            ignoredBeacons.add(id);
            monitoredBeacons.remove(id);
          } else {
            monitoredBeacons[id].rssi = scanResult.rssi;
            monitoredBeacons[id].distance = monitoredBeacons[id].Distance();
            monitoredBeacons[id].updateBeacon();
          }
        });
      }
    }
  }

  CustomDialog dialog = new CustomDialog();

  @override
  Widget build(BuildContext context) {
    //return new SpriteWidget(rc);
    return Material(
      
      child: Stack(
        children: <Widget>[
          AppBar(
            title: Text(widget.title),
          ),
          new SizedBox(width: 500, height: 500, child: new SpriteWidget(g)),
        ],
      ),
    );
  }
}
