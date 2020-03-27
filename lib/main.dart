import 'package:flutter/material.dart';
import 'package:medbridge_business/widget/SplashPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /*SharedPreferences.setMockInitialValues({});*/
  runApp(
    MaterialApp(
      home: SplashPage(),
    ),
  );
}
