import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

  Grid g;
  ProbabilityGrid probabilityGrid;
  NodeWithSize root;
  SpriteWidget sw;

  _MyHomePageState();

  @override
  void initState() {
    super.initState();



    root = new Root();

    sw = new SpriteWidget(root);
  }

  void getPos() {
    GridPos gridPos = probabilityGrid.getHighestProbPos();
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
          new Material(child:sw),
        ],
      ),
    );
  }
}
