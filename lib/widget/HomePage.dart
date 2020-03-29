import 'package:flutter/material.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/constants.dart';
import 'package:medbridge_business/widget/AddPatientPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Material(
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
        ),
      ),
    );
  }
}
