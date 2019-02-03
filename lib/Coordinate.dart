import 'dart:core';

class Coordinate {
  double x,y,r;

  Coordinate(double x, double y, double r){
    this.x = x;
    this.y = y;
    this.r = r;
  }
  double getX()
  {
    return x;
  }
  double getY()
  {
    return y;
  }

  void setX(double x)
  {
    this.x = x;
  }

  void setY(double y)
  {
    this.y = y;
  }
}