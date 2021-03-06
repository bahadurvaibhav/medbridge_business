import 'package:flutter/material.dart';
import 'package:medbridge_business/gateway/ApiUrlConstants.dart';
import 'package:medbridge_business/gateway/StatisticsResponse.dart';
import 'package:medbridge_business/gateway/gateway.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/StatusConstants.dart';
import 'package:medbridge_business/util/constants.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/widget/patient/PatientPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String totalPatients = "...";
  String treatmentsOngoing = "...";
  String treatmentsCompleted = "...";
  String rewardDue = "...";
  String rewardCollected = "...";

  @override
  void initState() {
    getStats();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              totalPatientsCard(totalPatients),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: <Widget>[
                    IntrinsicHeight(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: treatmentInfoCards(
                                TREATMENTS_ONGOING, treatmentsOngoing),
                          ),
                          Expanded(
                            child: treatmentInfoCards(
                                TREATMENTS_COMPLETED, treatmentsCompleted),
                          ),
                        ],
                      ),
                    ),
                    IntrinsicHeight(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: treatmentInfoCards(REWARD_DUE, rewardDue),
                          ),
                          Expanded(
                            child: treatmentInfoCards(
                                REWARD_COLLECTED, rewardCollected),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PatientPage(status: Status.NEW_PATIENT)),
                  );
                  getStats();
                },
                child: addNewPatient(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getStats() async {
    print("getStatistics API called");
    final prefs = await SharedPreferences.getInstance();
    int addedBy = prefs.getInt(USER_ID);
    var body = {
      "apiKey": API_KEY,
      "userId": addedBy.toString(),
    };
    final response = await post(GET_STATISTICS_URL, body);
    print(response.body);
    StatisticsResponse stats = statsResponseFromJson(response.body);
    setState(() {
      totalPatients = stats.totalPatients;
      treatmentsOngoing = stats.treatmentsOngoing;
      treatmentsCompleted = stats.treatmentsCompleted;
      rewardDue = "\$" + stats.rewardDue;
      rewardCollected = "\$" + stats.rewardCollected;
    });
  }

  Widget totalPatientsCard(String value) {
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
              value,
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

  Widget treatmentInfoCards(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Text(
              value,
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            ClipOval(
              child: Container(
                color: Colors.white,
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
