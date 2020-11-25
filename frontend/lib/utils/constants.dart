import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

const kTextFieldDecoration = InputDecoration(
  hintText: 'Enter a value',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(22.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black54, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(22.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.orange, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(22.0)),
  ),
);

const cities = [
  'Mumbai',
  'Delhi',
  'Tokyo',
  'Bengaluru',
  'Dubai',
  'Hong Kong',
  'Hyderabad',
  'Singapore',
  'Pune'
];

AlertStyle kAlertStyle = AlertStyle(
  animationType: AnimationType.grow,
  isCloseButton: true,
  isOverlayTapDismiss: true,
  descStyle: TextStyle(fontWeight: FontWeight.w300),
  animationDuration: Duration(milliseconds: 400),
  alertBorder: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20.0),
    side: BorderSide(
      color: Colors.grey,
    ),
  ),
  titleStyle: TextStyle(
    color: Colors.black,
  ),
);
var kDefaultTheme = ThemeData(
  primaryColor: Colors.white,
  brightness: Brightness.light,
  accentColor: Colors.orange,
  focusColor: Colors.orangeAccent,
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
      color: Colors.blue,
      style: BorderStyle.solid,
      width: 2,
    )),
//          labelText: "Product Name",
    labelStyle: TextStyle(
      color: Colors.deepOrangeAccent,
    ),
    hintStyle: TextStyle(
      color: Colors.grey[600],
    ),
//          hintText: "Enter your product name",

    // hintColor: Colors.blue,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    ),
  ),
  hintColor: Colors.deepOrange,
  textTheme: TextTheme(
    button: TextStyle(
      color: Color(0xFF252525),
      fontFamily: 'Montserrat',
    ),
    headline5: TextStyle(
        fontSize: 20.0, color: Colors.black, fontFamily: 'Montserrat'),
    headline4: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    headline3: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    headline2: TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    headline1: TextStyle(
      fontSize: 122.0,
      fontWeight: FontWeight.w300,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    subtitle1: TextStyle(
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    headline6: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    bodyText2: TextStyle(
      fontSize: 12.0,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    bodyText1: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
    caption: TextStyle(
      fontSize: 12.0,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
  ),
);
