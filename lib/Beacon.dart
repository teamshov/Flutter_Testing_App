import 'dart:math';

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