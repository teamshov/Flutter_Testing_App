import 'dart:core';
import 'dart:math';


class Coordinate {
  double x,y,r;

  Coordinate(this.x, this.y, this.r){}

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
}