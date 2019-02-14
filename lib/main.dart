import 'dart:core';
import 'package:flutter/material.dart';
import './UI/MyHomePage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShovTest',
      theme: ThemeData(

        primarySwatch: Colors.cyan,

      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

