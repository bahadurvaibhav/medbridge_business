import 'package:flutter/material.dart';
import 'package:medbridge_business/gateway/PatientResponse.dart';

class PatientCard extends StatefulWidget {
  final PatientResponse patientFromApi;

  PatientCard({Key key, @required this.patientFromApi}) : super(key: key);

  @override
  _PatientCardState createState() => _PatientCardState();
}

class _PatientCardState extends State<PatientCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'STATUS: PATIENT SUBMITTED',
                  style: TextStyle(letterSpacing: 0.7),
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Container(
                      height: 100,
                      child: Image.asset(
                        'images/patient.png',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.patientFromApi.patientName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.7,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(widget.patientFromApi.patientPhone),
                          SizedBox(height: 2),
                          Text(widget.patientFromApi.patientEmail),
                          SizedBox(height: 2),
                          Text(widget.patientFromApi.patientCountry),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
