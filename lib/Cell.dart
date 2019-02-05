import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import './Grid.dart';

class Cell extends NodeWithSize {
  Grid g;
  Rect r;
  Paint mypaint;
  Paint mypaint2;
  Cell(this.g, Size s, Offset p) : super(s) {
    position = p;
    r = Rect.fromPoints(p, p+Offset(s.width, s.height));
    mypaint = new Paint()
      ..color = Color.fromARGB(0, 255, 0, 0)
      ..style = PaintingStyle.fill;

    mypaint2 = new Paint()
      ..color = Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.stroke;

  }

  @override
  void paint(Canvas canvas) {
    super.paint(canvas);

    canvas.drawRect(r, mypaint);
    canvas.drawRect(r, mypaint2);
  }

}
