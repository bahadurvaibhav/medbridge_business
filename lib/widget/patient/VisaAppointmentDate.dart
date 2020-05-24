import 'package:flutter/material.dart';
import 'package:medbridge_business/gateway/ApiUrlConstants.dart';
import 'package:medbridge_business/gateway/VisaAppointmentDateResponse.dart';
import 'package:medbridge_business/gateway/gateway.dart';
import 'package:medbridge_business/util/StatusConstants.dart';
import 'package:medbridge_business/util/date.dart';
import 'package:medbridge_business/util/style.dart';

class VisaAppointmentDate extends StatefulWidget {
  final scaffoldKey;
  final Status status;
  final String patientId;

  VisaAppointmentDate({
    Key key,
    @required this.scaffoldKey,
    @required this.status,
    @required this.patientId,
  }) : super(key: key);

  @override
  _VisaAppointmentDateState createState() => _VisaAppointmentDateState();
}

class _VisaAppointmentDateState extends State<VisaAppointmentDate> {
  DateTime visaAppointmentDateTime;
  bool setVisaAppointmentDateApiInProgress = false;
  bool getVisaAppointmentDateApiCompleted = false;

  @override
  void initState() {
    super.initState();
    getVisaAppointmentDate();
  }

  @override
  Widget build(BuildContext context) {
    return viewableVisaAppointmentDate();
  }

  void getVisaAppointmentDate() async {
    setState(() {
      getVisaAppointmentDateApiCompleted = false;
    });
    var body = {
      "patientId": widget.patientId,
      "apiKey": API_KEY,
    };
    final response = await post(GET_VISA_APPOINTMENT_DATE_URL, body);
    VisaAppointmentDateResponse statusMsg =
        visaAppointmentDateResponseFromJson(response.body);
    print(response.body.toString());
    if (statusMsg.response.status == 200) {
      visaAppointmentDateTime = statusMsg.visaAppointmentDate;
      setState(() {
        getVisaAppointmentDateApiCompleted = true;
      });
    }
  }

  Widget viewableVisaAppointmentDate() {
    String visaAppointmentDateString = "...";
    if (getVisaAppointmentDateApiCompleted) {
      visaAppointmentDateString = getDateDisplay(visaAppointmentDateTime, '-');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        visaAppointmentDateHeading(),
        spaceHeadingToValue,
        Text(visaAppointmentDateString),
        spaceToNextField,
      ],
    );
  }

  Widget spaceHeadingToValue = SizedBox(height: 8);
  Widget spaceToNextField = SizedBox(height: 16);

  Widget visaAppointmentDateHeading() {
    return Text(
      'VISA APPOINTMENT DATE:',
      style: addPatientHeadingStyle(),
    );
  }
}
