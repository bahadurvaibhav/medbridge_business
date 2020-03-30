import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medbridge_business/gateway/PatientResponse.dart';
import 'package:medbridge_business/gateway/gateway.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/constants.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/widget/AddPatientPage.dart';
import 'package:medbridge_business/widget/PatientCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientsPage extends StatefulWidget {
  @override
  _PatientsPageState createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<PatientResponse> patients = [];
  bool apiCallDone = false;

  @override
  void initState() {
    super.initState();
    getPatients();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xfff0f0f0),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: 0, bottom: 75),
                      height: MediaQuery.of(context).size.height,
                      width: double.infinity,
                      child: Stack(
                        children: <Widget>[
                          loadingList(),
                          Container(
                            alignment: Alignment(1.0, -1.0),
                            padding: EdgeInsets.only(top: 10, right: 20),
                            child: SizedBox(
                              child: GestureDetector(
                                onTap: addNewPatient,
                                child: Text(
                                  "ADD PATIENT",
                                  style: TextStyle(
                                    color: primary,
                                    fontFamily: "Lato",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                showNoCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loadingList() {
    if (!apiCallDone) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitChasingDots(color: primary),
          SizedBox(height: 10),
          Text(
            'Loading...',
            style: TextStyle(
              color: primary,
            ),
          ),
        ],
      );
    } else {
      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: getPatients,
        child: ListView.builder(
          itemCount: patients.length,
          itemBuilder: (BuildContext context, int index) {
            return /*PatientCard(
              patientFromApi: patients[index],
            );*/
                Text(patients[index].patientName);
          },
        ),
      );
    }
  }

  Future<void> getPatients() async {
    setState(() {
      apiCallDone = false;
    });
    print("getPatients API called");
    final prefs = await SharedPreferences.getInstance();
    int addedBy = prefs.getInt(USER_ID);
    var body = {
      "apiKey": API_KEY,
      "userId": addedBy.toString(),
    };
    final response = await post(GET_PATIENTS_URL, body);
    print(response.body);
    List<PatientResponse> sentOffers = patientResponseFromJson(response.body);
    sentOffers.sort((a, b) {
      return b.created.compareTo(a.created);
    });
    setState(() {
      patients = sentOffers;
      apiCallDone = true;
    });
  }

  Widget showNoCards() {
    if (patients.length == 0 && apiCallDone) {
      return Center(
        child: Container(
          padding: EdgeInsets.only(top: 200, bottom: 75),
          child: Column(
            children: <Widget>[
              Text("No patients added"),
              Container(
                child: Align(
                  child: RaisedButton(
                    onPressed: addNewPatient,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.0)),
                    child: Text("Add Patient",
                        style: TextStyle(color: Colors.white70)),
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox();
  }

  addNewPatient() async {
    print("createOffer() clicked");
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPatientPage()),
    );
    getPatients();
  }
}