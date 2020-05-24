import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:medbridge_business/domain/DocumentMetadata.dart';
import 'package:medbridge_business/gateway/ApiUrlConstants.dart';
import 'package:medbridge_business/gateway/ResponseWithId.dart';
import 'package:medbridge_business/gateway/StatusMsg.dart';
import 'package:medbridge_business/gateway/TravelStatusResponse.dart';
import 'package:medbridge_business/gateway/document/DocumentConstants.dart';
import 'package:medbridge_business/gateway/gateway.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/StatusConstants.dart';
import 'package:medbridge_business/util/date.dart';
import 'package:medbridge_business/util/file.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/util/snackbar.dart';
import 'package:medbridge_business/util/style.dart';
import 'package:medbridge_business/util/validate.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelUpdates extends StatefulWidget {
  final bool isEditable;
  final scaffoldKey;
  final Status status;
  final bool travelAssistYes;
  final bool accoAssistYes;
  final String patientId;

  TravelUpdates({
    Key key,
    @required this.isEditable,
    @required this.scaffoldKey,
    @required this.status,
    @required this.patientId,
    @required this.travelAssistYes,
    @required this.accoAssistYes,
  }) : super(key: key);

  @override
  _TravelUpdatesState createState() => _TravelUpdatesState();
}

class _TravelUpdatesState extends State<TravelUpdates> {
  bool passportFileUploadingInProgress = false;
  List<DocumentMetadata> uploadedPassportDocuments = new List();

  bool visaAppointmentFileUploadingInProgress = false;
  List<DocumentMetadata> uploadedVisaAppointmentDocuments = new List();

  DateTime arrivalDateTime;
  DateTime visaAppointmentDateTime;

  TextEditingController budgetController = new TextEditingController();
  FocusNode budgetFocus = FocusNode();

  final _budgetFormKey = GlobalKey<FormState>();
  bool getTravelStatusApiCompleted = false;
  bool travelStatusUpdateApiInProgress = false;
  TravelStatus travelStatus;

  @override
  void initState() {
    super.initState();
    if (!widget.isEditable) {
      getTravelStatusUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget showItems = Center(child: CircularProgressIndicator());
    if (!widget.isEditable) {
      if (getTravelStatusApiCompleted) {
        showItems = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            viewableTravelUpdates(),
            viewableVisaAppointment(),
            showDocuments(
              'Visa Appointment Form',
              uploadedVisaAppointmentDocuments,
              visaAppointmentFileUploadingInProgress,
              chooseFileVisaAppointmentFormClicked,
            ),
          ],
        );
      } else {
        showItems = Center(child: CircularProgressIndicator());
      }
    } else {
      showItems = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          editableTravelUpdates(),
          editableVisaAppointment(),
          spaceToNextField,
          showSubmitButton(),
        ],
      );
    }

    return showItems;
  }

  void getTravelStatusUpdate() async {
    setState(() {
      getTravelStatusApiCompleted = false;
    });
    var body = {
      "apiKey": API_KEY,
      "patientId": widget.patientId,
    };
    final response = await post(GET_TRAVEL_STATUS_UPDATE_URL, body);
    TravelStatusResponse responseBody =
        travelStatusResponseFromJson(response.body);
    if (responseBody.response.status == 200) {
      travelStatus = responseBody.travelStatus;
      travelStatus.passportDocuments.forEach((element) {
        uploadedPassportDocuments
            .add(documentMetadataFrom(element, 'PASSPORT'));
      });
      travelStatus.visaAppointmentDocuments.forEach((element) {
        uploadedVisaAppointmentDocuments
            .add(documentMetadataFrom(element, 'VISA APPOINTMENT FORM'));
      });
      setState(() {
        getTravelStatusApiCompleted = true;
      });
    }
  }

  DocumentMetadata documentMetadataFrom(Document document, String description) {
    return new DocumentMetadata(
      int.tryParse(document.id),
      description,
      document.documentName,
      document.storedDocumentName,
    );
  }

  Widget showSubmitButton() {
    if (!widget.isEditable) {
      return SizedBox();
    }
    Widget text = SizedBox();
    if (travelStatusUpdateApiInProgress) {
      text = CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      text = Text(
        "Submit",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 24,
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

  Future<void> buttonClicked() async {
    print('Submit in Travel updates clicked');
    setState(() {
      travelStatusUpdateApiInProgress = true;
    });
    if (widget.accoAssistYes) {
      if (!_budgetFormKey.currentState.validate()) {
        print('Travel status form invalid');
        setState(() {
          travelStatusUpdateApiInProgress = false;
        });
        return;
      }
    }
    if (widget.travelAssistYes) {
      if (uploadedPassportDocuments.length == 0) {
        print('No passport uploaded');
        widget.scaffoldKey.currentState.showSnackBar(
          showSnackbarWith("Please upload passport"),
        );
        setState(() {
          travelStatusUpdateApiInProgress = false;
        });
        return;
      }
      if (uploadedVisaAppointmentDocuments.length == 0) {
        print('No visa appointment form uploaded');
        widget.scaffoldKey.currentState.showSnackBar(
          showSnackbarWith("Please upload visa appointment form"),
        );
        setState(() {
          travelStatusUpdateApiInProgress = false;
        });
        return;
      }
    }
    print('Travel status form and documents valid');

    var body = {
      "apiKey": API_KEY,
      "patientId": widget.patientId,
      "budgetForAcco": budgetController.text,
      "arrivalDate": getDateString(arrivalDateTime),
      "visaAppointmentDate": getDateString(visaAppointmentDateTime),
      "uploadedPassport": getDocumentsString(uploadedPassportDocuments),
      "uploadedVisaAppointmentForm":
          getDocumentsString(uploadedVisaAppointmentDocuments),
    };
    final response = await post(TRAVEL_STATUS_UPDATE_URL, body);
    StatusMsg statusMsg = responseFromJson(response.body);
    if (statusMsg.status == 200) {
      widget.scaffoldKey.currentState.showSnackBar(
        showSnackbarWithCheck("Submitted successfully"),
      );
      Navigator.pop(context);
    } else {
      widget.scaffoldKey.currentState.showSnackBar(
        showSnackbarWith("Unable to submit. Try again later"),
      );
    }
    setState(() {
      travelStatusUpdateApiInProgress = false;
    });
  }

  String getDocumentsString(List<DocumentMetadata> documents) {
    List<String> documentIds = new List();
    documents.forEach((document) {
      documentIds.add(
        document.documentId.toString(),
      );
    });
    return documentIds.join(",");
  }

  Widget viewableVisaAppointment() {
    String visaAppointmentDate = "-";
    if (travelStatus.visaAppointmentDate.isNotEmpty) {
      visaAppointmentDateTime =
          DateTime.parse(travelStatus.visaAppointmentDate);
      visaAppointmentDate = getDateDisplay(visaAppointmentDateTime, '-');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        divider(),
        visaAppointmentHeading(),
        spaceToNextField,
        Text(
          'Desired Visa Appointment Date:',
          style: goldenHeadingStyle(),
        ),
        spaceHeadingToValue,
        Text(visaAppointmentDate),
        spaceToNextField,
      ],
    );
  }

  Widget editableVisaAppointment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        divider(),
        visaAppointmentHeading(),
        SizedBox(height: 12),
        showVisaAppointmentDate(),
        SizedBox(height: 6),
        downloadVisaAppointmentFormButton(),
        SizedBox(height: 6),
        showDocuments(
          'Visa Appointment Form',
          uploadedVisaAppointmentDocuments,
          visaAppointmentFileUploadingInProgress,
          chooseFileVisaAppointmentFormClicked,
        ),
      ],
    );
  }

  Widget downloadVisaAppointmentFormButton() {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      color: primary,
      icon: Icon(
        Icons.file_download,
        color: Colors.white,
      ),
      label: Text(
        "Download Visa Appointment Form",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: shareVisaAppointmentForm,
    );
  }

  Future<void> shareVisaAppointmentForm() async {
    var tempDir = await getTemporaryDirectory();
    String fullPath = tempDir.path + "/Info_for_Visa.doc";
    print('download to path ${fullPath}');
    String urlPath = DOWNLOAD_VISA_APPOINTMENT_URL;
    print('download from ${urlPath}');
    await Dio().download(urlPath, fullPath);

    showWordDocument(fullPath);
  }

  Widget visaAppointmentHeading() {
    return Text(
      'VISA APPOINTMENT FORM:',
      style: addPatientHeadingStyle(),
    );
  }

  Widget editableTravelUpdates() {
    Widget accoAssistWidgets = SizedBox();
    if (widget.accoAssistYes) {
      accoAssistWidgets = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Form(
            key: _budgetFormKey,
            child: TextFormField(
              controller: budgetController,
              focusNode: budgetFocus,
              style: TextStyle(color: Colors.blue),
              validator: validateName,
              decoration: InputDecoration(
                hintText: 'Budget for accomodation*',
              ),
            ),
          ),
        ],
      );
    }

    Widget travelAssistWidgets = SizedBox();
    if (widget.travelAssistYes) {
      travelAssistWidgets = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          showArrivalDate(),
          SizedBox(height: 6),
          showDocuments(
            'Passport',
            uploadedPassportDocuments,
            passportFileUploadingInProgress,
            chooseFilePassportClicked,
          ),
          SizedBox(height: 6),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        travelUpdatesHeading(),
        SizedBox(height: 6),
        accoAssistWidgets,
        SizedBox(height: 12),
        travelAssistWidgets,
        SizedBox(height: 6),
      ],
    );
  }

  Widget travelUpdatesHeading() {
    return Text(
      'TRAVEL UPDATES:',
      style: addPatientHeadingStyle(),
    );
  }

  Widget showVisaAppointmentDate() {
    Function onConfirm = (date) {
      visaAppointmentDateTime = date;
      setState(() {});
    };
    return showDate(
      context,
      widget.isEditable,
      visaAppointmentDateTime,
      onConfirm,
      "Desired VISA Appointment Date",
    );
  }

  Widget showArrivalDate() {
    Function onConfirm = (date) {
      arrivalDateTime = date;
      setState(() {});
    };
    return showDate(
      context,
      widget.isEditable,
      arrivalDateTime,
      onConfirm,
      "Expected Arrival Date",
    );
  }

  viewDocument(DocumentMetadata uploadedDocument) async {
    print('downloadDocument() clicked');

    String storedFileName = uploadedDocument.storedDocumentName;

    String fullPath = "";

    if (widget.isEditable) {
      fullPath = storedFileName;
    } else {
      var tempDir = await getTemporaryDirectory();
      fullPath = tempDir.path + "/" + storedFileName + "'";
      print('download to path ${fullPath}');

      String urlPath = DOWNLOAD_DOCUMENT_URL + storedFileName;
      print('download from ${urlPath}');
      await Dio().download(urlPath, fullPath);
    }

    await viewFile(context, uploadedDocument, fullPath);
  }

  Widget showDocuments(String title, List<DocumentMetadata> documents,
      bool fileUploadingInProgress, Function fileClicked) {
    Widget addDocument = SizedBox();
    if (widget.isEditable) {
      addDocument = Form(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Upload ' + title,
                style: goldenHeadingStyle(),
              ),
            ),
            SizedBox(width: 10),
            RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              color: primary,
              icon: Icon(
                Icons.file_upload,
                color: Colors.white,
              ),
              label: Text(
                "Choose File",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: fileClicked,
            ),
          ],
        ),
      );
    }

    Widget listView = Center(child: CircularProgressIndicator());
    if (documents.length > 0) {
      listView = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: documents.length,
        itemBuilder: (BuildContext ctxt, int index) {
          DocumentMetadata uploadedDocument = documents[index];
          return showDocument(uploadedDocument);
        },
      );
    } else {
      listView = Center(
        child: Text(
          'No ' + title + ' found',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    Widget fileUploadingProgress = SizedBox();
    if (fileUploadingInProgress) {
      fileUploadingProgress = Center(child: CircularProgressIndicator());
    } else {
      fileUploadingProgress = SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        addDocument,
        SizedBox(
          height: 20,
        ),
        fileUploadingProgress,
        listView,
      ],
    );
  }

  Widget showDocument(DocumentMetadata uploadedDocument) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(uploadedDocument.description)),
          SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: () => viewDocument(uploadedDocument),
              child: Row(
                children: <Widget>[
                  Icon(Icons.attach_file),
                  Flexible(
                    child: Text(
                      uploadedDocument.fileName,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  chooseFilePassportClicked() async {
    setState(() {
      passportFileUploadingInProgress = true;
    });
    widget.scaffoldKey.currentState.showSnackBar(uploadingDocumentSnackbar());
    File file = await FilePicker.getFile();
    print('File picked');
    if (file == null || !await isFileValid(file, context)) {
      widget.scaffoldKey.currentState.hideCurrentSnackBar();
      return;
    }
    int referenceId = await uploadDocument(file);
    uploadedPassportDocuments.add(
      new DocumentMetadata(
          referenceId, 'PASSPORT', getFileName(file), file.path),
    );
    widget.scaffoldKey.currentState.hideCurrentSnackBar();
    widget.scaffoldKey.currentState
        .showSnackBar(showSnackbarWithCheck("File uploaded"));
    setState(() {
      passportFileUploadingInProgress = false;
    });
    setState(() {});
  }

  chooseFileVisaAppointmentFormClicked() async {
    setState(() {
      visaAppointmentFileUploadingInProgress = true;
    });
    widget.scaffoldKey.currentState.showSnackBar(uploadingDocumentSnackbar());
    File file = await FilePicker.getFile();
    print('File picked');
    if (file == null || !await isFileValid(file, context)) {
      widget.scaffoldKey.currentState.hideCurrentSnackBar();
      return;
    }
    int referenceId = await uploadDocument(file);
    uploadedVisaAppointmentDocuments.add(
      new DocumentMetadata(
          referenceId, 'VISA APPOINTMENT FORM', getFileName(file), file.path),
    );
    widget.scaffoldKey.currentState.hideCurrentSnackBar();
    widget.scaffoldKey.currentState
        .showSnackBar(showSnackbarWithCheck("File uploaded"));
    setState(() {
      visaAppointmentFileUploadingInProgress = false;
    });
    setState(() {});
  }

  Future<int> uploadDocument(File file) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt(USER_ID).toString();

    FormData formData = new FormData.fromMap({
      "apiKey": API_KEY,
      "userId": userId,
      "file": await MultipartFile.fromFile(
        file.path,
        filename: getFileName(file),
      ),
    });
    Response response = await Dio().post(UPLOAD_DOCUMENT_URL, data: formData);
    ResponseWithId statusMsg = responseWithIdFromJson(response.data);
    if (statusMsg.response.status == 203) {
      // Unable to upload due to database or upload error
    } else if (statusMsg.response.status == 202) {
      // File extension not allowed
      showDocumentErrorDialog(
        context,
        DOCUMENT_INVALID_EXTENSION_TITLE,
        DOCUMENT_INVALID_EXTENSION_SUBTITLE +
            ALLOWED_DOCUMENT_EXTENSIONS.toString(),
      );
    } else if (statusMsg.response.status == 201) {
      // File bigger than limit
      showDocumentErrorDialog(
        context,
        DOCUMENT_MAX_SIZE_EXCEEDED_TITLE,
        DOCUMENT_MAX_SIZE_EXCEEDED_SUBTITLE,
      );
    }
    print("File upload response: $response");
    return statusMsg.referenceId;
  }

  String getFileName(File file) {
    return path.basename(file.path);
  }

  Widget spaceHeadingToValue = SizedBox(height: 8);
  Widget spaceToNextField = SizedBox(height: 16);

  Widget viewableTravelUpdates() {
    Widget accoAssistWidgets = SizedBox();
    if (widget.accoAssistYes) {
      accoAssistWidgets = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Budget for accomodation:',
            style: goldenHeadingStyle(),
          ),
          Text(travelStatus.budgetForAcco),
        ],
      );
    }

    Widget travelAssistWidgets = SizedBox();
    if (widget.travelAssistYes) {
      String arrivalDate = "-";
      if (travelStatus.arrivalDate.isNotEmpty) {
        arrivalDateTime = DateTime.parse(travelStatus.arrivalDate);
        arrivalDate = getDateDisplay(arrivalDateTime, '-');
      }
      travelAssistWidgets = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Expected Arrival Date:',
            style: goldenHeadingStyle(),
          ),
          spaceHeadingToValue,
          Text(arrivalDate),
          spaceToNextField,
          showDocuments(
            'Passport',
            uploadedPassportDocuments,
            passportFileUploadingInProgress,
            chooseFilePassportClicked,
          ),
          spaceToNextField,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        travelUpdatesHeading(),
        spaceToNextField,
        accoAssistWidgets,
        spaceToNextField,
        travelAssistWidgets,
        spaceHeadingToValue,
      ],
    );
  }
}
