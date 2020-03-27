import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/widget/HomePage.dart';
import 'package:medbridge_business/widget/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatelessWidget {
  showNextScreen(BuildContext context) {
    Timer(Duration(seconds: 1), () async {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(IS_LOGGED_IN) == null || !prefs.getBool(IS_LOGGED_IN)) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    showNextScreen(context);
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              color: Color(0xFF0274BB),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.asset(
                    "images/medbridge.jpg",
                    fit: BoxFit.fill,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 11),
                  child: Text(
                    "Business",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
