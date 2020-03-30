import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/widget/HomePage.dart';
import 'package:medbridge_business/widget/PatientsPage.dart';
import 'package:medbridge_business/widget/onboarding/OnboardingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigationPage extends StatefulWidget {
  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: appBar(),
        body: SafeArea(
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            controller: pageController,
            children: <Widget>[
              HomePage(),
              PatientsPage(),
            ],
          ),
        ),
        bottomNavigationBar: bottomNavigationBar(),
      ),
    );
  }

  Widget bottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('HOME'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          title: Text('PATIENTS'),
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: primary,
      onTap: (index) => pageController.jumpToPage(index),
    );
  }

  Widget appBar() {
    return new AppBar(
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 20.0, 0),
          child: GestureDetector(
            onTap: showLogoutDialog,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        )
      ],
      automaticallyImplyLeading: false,
    );
  }

  Future<void> showLogoutDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () async {
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              preferences.clear();
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OnboardingPage()),
              );
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}
