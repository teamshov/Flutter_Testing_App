import 'package:flutter/material.dart';
import 'dart:core';



class CustomDialog{
  information(BuildContext context, String title, String description){
    return showDialog(
      context:context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(

              children: <Widget>[
                Text(description)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Ok'),
            )
          ]
        );
      }
    );
  }
}