import 'package:flutter/material.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/widget/SplashPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /*// add to logout
  SharedPreferences.setMockInitialValues({
    IS_LOGGED_IN: false,
  });*/
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashPage(),
    );
  }
}
