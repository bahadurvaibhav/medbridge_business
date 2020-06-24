import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:medbridge_business/domain/DocumentMetadata.dart';
import 'package:medbridge_business/gateway/ApiUrlConstants.dart';
import 'package:medbridge_business/gateway/StatusMsg.dart';
import 'package:medbridge_business/gateway/TravelStatusConfirmedResponse.dart';
import 'package:medbridge_business/gateway/gateway.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/StatusConstants.dart';
import 'package:medbridge_business/util/file.dart';
import 'package:medbridge_business/util/snackbar.dart';
import 'package:medbridge_business/util/style.dart';

class TravelStatus extends StatefulWidget {
  final bool isEditable;
  final scaffoldKey;
  final Status status;
  final String patientId;

  TravelStatus({
    Key key,
    @required this.isEditable,
    @required this.scaffoldKey,
    @required this.status,
    @required this.patientId,
  }) : super(key: key);

  @override
  _TravelStatusState createState() => _TravelStatusState();
}

class _TravelStatusState extends State<TravelStatus> {
  Widget spaceToNextField = SizedBox(height: 16);

  bool updateStatusVisaAppointmentInProgress = false;

  bool flightTicketFileUploadingInProgress = false;
  List<DocumentMetadata> uploadedFlightTicketDocuments = new List();

  @override
  void initState() {
    super.initState();
    if (!widget.isEditable) {
      getTravelStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditable) {
      return editableTravelStatus();
    }
    return viewableTravelStatus();
  }

  bool getTravelStatusApiCompleted = false;

  getTravelStatus() async {
    setState(() {
      getTravelStatusApiCompleted = false;
    });
    var body = {
      "apiKey": API_KEY,
      "patientId": widget.patientId,
    };
    final response = await post(GET_TRAVEL_STATUS_CONFIRMED_URL, body);
    TravelStatusConfirmedResponse responseBody =
        travelStatusConfirmedResponseFromJson(response.body);
    if (responseBody.response.status == 200) {
      selectedPickUpRequestedRadioValue =
          responseBody.travelStatus.pickUpRequested;
      responseBody.travelStatus.flightTicketDocuments.forEach((element) {
        uploadedFlightTicketDocuments
            .add(documentMetadataFrom(element, 'FLIGHT TICKETS'));
      });
      setState(() {
        getTravelStatusApiCompleted = true;
      });
    }
  }

  Widget viewableTravelStatus() {
    if (getTravelStatusApiCompleted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          travelStatusHeading(),
          SizedBox(height: 6),
          showDocuments(
            context,
            widget.isEditable,
            'Flight Ticket',
            uploadedFlightTicketDocuments,
            flightTicketFileUploadingInProgress,
            chooseFileFormClicked,
          ),
          spaceToNextField,
          Text(PICK_UP_REQUESTED, style: goldenHeadingStyle()),
          Text(selectedPickUpRequestedRadioValue),
          spaceToNextField,
        ],
      );
    }
    return Center(child: CircularProgressIndicator());
  }

  String PICK_UP_REQUESTED = 'Pick up requested';

  Widget travelStatusHeading() {
    return Text(
      'TRAVEL STATUS:',
      style: addPatientHeadingStyle(),
    );
  }

  Widget editableTravelStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        travelStatusHeading(),
        SizedBox(height: 6),
        showDocuments(
          context,
          widget.isEditable,
          'Flight Ticket',
          uploadedFlightTicketDocuments,
          flightTicketFileUploadingInProgress,
          chooseFileFormClicked,
        ),
        spaceToNextField,
        Text(PICK_UP_REQUESTED),
        selectPickUpRequested(),
        spaceToNextField,
        showSubmitButtonWithTitle(
          updateStatusVisaAppointmentInProgress,
          updateStatusVisaAppointmentClicked,
          "Click here if " +
              statusReadable.reverse[Status.VISA_APPOINTMENT] +
              " completed",
          18,
        ),
      ],
    );
  }

  chooseFileFormClicked() async {
    setState(() {
      flightTicketFileUploadingInProgress = true;
    });
    widget.scaffoldKey.currentState.showSnackBar(uploadingDocumentSnackbar());
    File file = await FilePicker.getFile();
    print('File picked');
    if (file == null || !await isFileValid(file, context)) {
      widget.scaffoldKey.currentState.hideCurrentSnackBar();
      return;
    }
    int referenceId = await uploadDocument(context, file);
    uploadedFlightTicketDocuments.add(
      new DocumentMetadata(
          referenceId, 'VISA APPOINTMENT FORM', getFileName(file), file.path),
    );
    widget.scaffoldKey.currentState.hideCurrentSnackBar();
    widget.scaffoldKey.currentState
        .showSnackBar(showSnackbarWithCheck("File uploaded"));
    setState(() {
      flightTicketFileUploadingInProgress = false;
    });
    setState(() {});
  }

  String selectedPickUpRequestedRadioValue = "";
  bool pickUpRequestedInvalid = false;

  pickUpRequestedRadioChanged(String value) {
    setState(() {
      selectedPickUpRequestedRadioValue = value;
    });
  }

  Widget selectPickUpRequested() {
    Widget pickUpErrorText = SizedBox();
    if (pickUpRequestedInvalid) {
      pickUpErrorText = Text(
        'Select one option',
        style: TextStyle(
          color: Colors.red,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            new Radio(
              value: "Yes",
              groupValue: selectedPickUpRequestedRadioValue,
              onChanged: pickUpRequestedRadioChanged,
            ),
            new Text(
              'Yes',
              style: new TextStyle(fontSize: 16.0),
            ),
            new Radio(
              value: "No",
              groupValue: selectedPickUpRequestedRadioValue,
              onChanged: pickUpRequestedRadioChanged,
            ),
            new Text(
              'No',
              style: new TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        pickUpErrorText,
      ],
    );
  }

  updateStatusVisaAppointmentClicked() async {
    setState(() {
      updateStatusVisaAppointmentInProgress = true;
      pickUpRequestedInvalid = false;
    });
    if (selectedPickUpRequestedRadioValue.isEmpty) {
      setState(() {
        updateStatusVisaAppointmentInProgress = false;
        pickUpRequestedInvalid = true;
      });
      return;
    }
    if (uploadedFlightTicketDocuments.length == 0) {
      setState(() {
        updateStatusVisaAppointmentInProgress = false;
      });
      return;
    }
    var body = {
      "flightTicketDocuments":
          getDocumentsString(uploadedFlightTicketDocuments),
      "pickUpRequested": selectedPickUpRequestedRadioValue,
      "patientId": widget.patientId,
      "apiKey": API_KEY,
    };
    print(body.toString());
    final response = await post(UPDATE_STATUS_VISA_APPOINTMENT_URL, body);
    StatusMsg statusMsg = responseFromJson(response.body);
    if (statusMsg.status == 200) {
      print('Status visa appointment update API success');
      setState(() {
        updateStatusVisaAppointmentInProgress = false;
      });
      widget.scaffoldKey.currentState
          .showSnackBar(showSnackbarWithCheck("Status updated successfully"));
      Navigator.pop(context);
    } else {
      print('Status visa appointment update API failed with msg: ' +
          statusMsg.msg);
      setState(() {
        updateStatusVisaAppointmentInProgress = false;
      });
      widget.scaffoldKey.currentState.showSnackBar(
          showSnackbarWith("Unable to update status. Try again later."));
    }
  }

  Widget showSubmitButtonWithTitle(
      bool inProgress, Function buttonClicked, String title, double fontSize) {
    Widget text = SizedBox();
    if (inProgress) {
      text = CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      text = Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: fontSize,
          letterSpacing: 1.2,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: primary,
            child: Container(
              height: 50,
              child: Center(child: text),
            ),
            onPressed: buttonClicked,
          ),
        ),
      ],
    );
  }
}
