import 'dart:convert';
import 'dart:math';
import 'dart:core';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_blue/flutter_blue.dart';

const int timeoutDuration = 10000; //in ms

class Beacon{
  String UUID;
  double x=0;
  double y=0;
  double offset=0;
  int rssi=0;
  double distance=0;
  int timeLastSeen;
  bool isWithinRange = false;


  Beacon(this.UUID);


  double Distance(){
    double dist = 0.0;
    dist = pow(10, ((offset-rssi)/20));
    return dist;
  }

  void updateBeacon(){
    timeLastSeen = new DateTime.now().millisecondsSinceEpoch;
  }

  bool checkIsWithinRange(){
    var timeNow = new DateTime.now().millisecondsSinceEpoch;
    if (timeNow-timeLastSeen > timeoutDuration)
      isWithinRange = false;
    else
      isWithinRange = true;

    return isWithinRange;
  }
}

class BeaconScanner {
  Map<String, Beacon> monitoredBeacons = new Map<String, Beacon>();
  List<String> ignoredBeacons = new List<String>();
  FlutterBlue flutterBlue = FlutterBlue.instance;

  BeaconScanner() {
    flutterBlue.scan(scanMode: ScanMode.lowLatency).listen(this.bluetoothscan);
  }

  void bluetoothscan(scanResult) async {
    var servicedata = scanResult.advertisementData.serviceData;
    if (servicedata.length > 0) {
      var data = servicedata.entries.toList().elementAt(0).value;
      if (data.isNotEmpty && (data.elementAt(0) & 0x0F == 0x02)) {
        var id = "";

        data.sublist(1, 9).forEach((int f) {
          id += f.toRadixString(16).padLeft(2, "0");
        });

        if (!monitoredBeacons.containsKey(id) || !ignoredBeacons.contains(id)) {
          monitoredBeacons[id] = new Beacon(id);
          monitoredBeacons[id].updateBeacon();
        }
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

      }
    }
  }
}