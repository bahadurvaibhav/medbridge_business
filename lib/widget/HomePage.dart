import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/constants.dart';
import 'package:medbridge_business/widget/AddPatientPage.dart';
import 'package:medbridge_business/widget/PatientsPage.dart';
import 'package:medbridge_business/widget/onboarding/OnboardingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              homePage(),
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

  Widget homePage() {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            totalPatientsCard(35),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: treatmentInfoCards(TREATMENTS_ONGOING, 7),
                  ),
                  Expanded(
                    child: treatmentInfoCards(TREATMENTS_COMPLETED, 16),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPatientPage()),
                );
              },
              child: addNewPatient(),
            ),
          ],
        ),
      ),
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

  Widget totalPatientsCard(int value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              TOTAL_PATIENTS,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 40,
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget treatmentInfoCards(String title, int value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 40,
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addNewPatient() {
    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              ADD_NEW_PATIENT,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            ClipOval(
              child: Container(
                color: Colors.white,
                child: Icon(
                  Icons.add,
                  size: 45,
                  color: primary,
                ),
              ),
            ),
            /*Icon(
              Icons.add_circle,
              size: 45,
              color: primary,
            ),*/
          ],
        ),
      ),
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
