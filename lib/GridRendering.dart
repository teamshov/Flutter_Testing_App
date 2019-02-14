
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:spritewidget/spritewidget.dart';
import './Cell.dart';

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

class Grid extends NodeWithSize {
  int cellSize;
  int widthincells;
  int heightincells;
  String paraText = " ajsdkajshjd \n ahsijgdhjks  \n a d s sarf \n sdaf ";
  ParagraphBuilder pb = new ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center, fontFamily: "Arial", fontSize: 1, fontWeight: FontWeight.normal, fontStyle: FontStyle.normal, textDirection: TextDirection.ltr, ellipsis: "..."));
  Paragraph para;

  List<Cell> cells;
  Grid(this.cellSize, Size s) : super(s) {
    widthincells = (size.width/cellSize).toInt();
    heightincells = (size.height/cellSize).toInt();
    var numberofcells = widthincells*heightincells;
    cells = new List(numberofcells);
    Size cs = Size(cellSize.toDouble(), cellSize.toDouble());
    for(int i = 0; i < numberofcells; i++) {
      var x = (i%widthincells)*cellSize/2;
      var y = (i/widthincells).toInt()*cellSize/2;
      Offset p = Offset(x.toDouble(),y.toDouble());
      Cell c = new Cell(this, cs, p);
      cells[i] = c;
      addChild(c);
    }
    pb.addText(paraText);
    para = pb.build();
    para.layout(ParagraphConstraints(width: 10.0));
  }

  void setColor(double x, double y, Color c) {
    int gridx = (x/cellSize).toInt();
    int gridy = (y/cellSize).toInt();

    if(gridx > widthincells || gridy > heightincells) {
      debugPrint("FUCCK! STAY INSIDE YOU LITTLE SHIT HEAD!");
      return;
    }

    int index = gridx + gridy*widthincells;
    cells[index].mypaint.color = c;
  }

  @override
  void paint(Canvas canvas) {
    super.paint(canvas);
    canvas.drawColor(Color.fromARGB(225, 0, 0, 0), BlendMode.clear);
    canvas.drawParagraph(para, Offset(1, 1));
  }

  @override
  update(double dt) {
    super.update(dt);
  }
}