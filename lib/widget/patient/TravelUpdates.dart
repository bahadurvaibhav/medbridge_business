import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:medbridge_business/domain/DocumentMetadata.dart';
import 'package:medbridge_business/gateway/ApiUrlConstants.dart';
import 'package:medbridge_business/gateway/ResponseWithId.dart';
import 'package:medbridge_business/gateway/document/DocumentConstants.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/StatusConstants.dart';
import 'package:medbridge_business/util/file.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/util/snackbar.dart';
import 'package:medbridge_business/util/style.dart';
import 'package:medbridge_business/util/validate.dart';
import 'package:medbridge_business/widget/ImageViewer.dart';
import 'package:medbridge_business/widget/PdfViewer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelUpdates extends StatefulWidget {
  final bool isEditable;
  final scaffoldKey;
  final Status status;
  final bool travelAssistYes;
  final bool accoAssistYes;

  TravelUpdates({
    Key key,
    @required this.isEditable,
    @required this.scaffoldKey,
    @required this.status,
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
  bool apiInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        travelUpdatesSection(),
        visaAppointmentSection(),
        SizedBox(height: 10),
        showSubmitButton(),
      ],
    );
  }

  Widget showSubmitButton() {
    Widget text = SizedBox();
    if (apiInProgress) {
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

  void buttonClicked() {
    print('Submit in Travel updates clicked');
    if (widget.accoAssistYes) {
      if (!_budgetFormKey.currentState.validate()) {
        print('Travel status form invalid');
        return;
      }
    }
    if (widget.travelAssistYes) {
      if (uploadedPassportDocuments.length == 0) {
        print('No passport uploaded');
        widget.scaffoldKey.currentState.showSnackBar(
          showSnackbarWith("Please upload passport"),
        );
        return;
      }
      if (uploadedVisaAppointmentDocuments.length == 0) {
        print('No visa appointment form uploaded');
        widget.scaffoldKey.currentState.showSnackBar(
          showSnackbarWith("Please upload visa appointment form"),
        );
        return;
      }
    }
    print('Travel status form and documents valid');
  }

  Widget visaAppointmentSection() {
    if (widget.isEditable) {
      return editableVisaAppointment();
    }
    return viewableVisaAppointment();
  }

  Widget viewableVisaAppointment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        divider(),
        visaAppointmentHeading(),
        Text('Visa appointment Viewable'),
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

    File file = new File(fullPath);
    Uint8List bytes = file.readAsBytesSync();
    final ByteData byteData = ByteData.view(bytes.buffer);
    await Share.file(
      'Info_for_Visa',
      'Info_for_Visa.doc',
      byteData.buffer.asUint8List(),
      'application/msword',
    );
  }

  Widget visaAppointmentHeading() {
    return Text(
      'VISA APPOINTMENT FORM:',
      style: addPatientHeadingStyle(),
    );
  }

  Widget travelUpdatesSection() {
    if (widget.isEditable) {
      return editableTravelUpdates();
    }
    return viewableTravelUpdates();
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
    return showDate(arrivalDateTime, onConfirm, "Expected Arrival Date");
  }

  void showDatePicker(Function onConfirm) {
    DatePicker.showDatePicker(
      context,
      theme: DatePickerTheme(
        containerHeight: 210.0,
      ),
      showTitleActions: true,
      minTime: DateTime.now(),
      onConfirm: onConfirm,
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
  }

  Widget showDate(DateTime dateTime, Function onConfirm, String hintText) {
    Function updateDate = () {};
    Widget changeText = SizedBox();
    if (widget.isEditable) {
      changeText = Text(
        "  Change",
        style: TextStyle(
          color: primary,
          fontSize: 16.0,
        ),
      );
      updateDate = () {
        showDatePicker(onConfirm);
      };
    }
    return FlatButton(
      onPressed: updateDate,
      child: Container(
        alignment: Alignment.center,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.date_range,
                        size: 18.0,
                        color: primary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        getDateDisplay(dateTime, hintText),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            changeText,
          ],
        ),
      ),
      color: Colors.white,
    );
  }

  String getDateDisplay(DateTime date, String hintText) {
    if (date == null) {
      return hintText;
    }
    return '${date.year} - ${date.month} - ${date.day}';
  }

  viewDocument(DocumentMetadata uploadedDocument) async {
    print('downloadDocument() clicked');

    String fileName = uploadedDocument.fileName;
    String storedFileName = uploadedDocument.storedDocumentName;
    String fileExtension =
        storedFileName.substring(storedFileName.lastIndexOf(".") + 1);
    print('File extension: ' + fileExtension);
    String fullPath = "";

    if (widget.status == Status.NEW_PATIENT) {
      fullPath = storedFileName;
    } else {
      var tempDir = await getTemporaryDirectory();
      fullPath = tempDir.path + "/" + storedFileName + "'";
      print('download to path ${fullPath}');

      String urlPath = DOWNLOAD_DOCUMENT_URL + storedFileName;
      print('download from ${urlPath}');
      await Dio().download(urlPath, fullPath);
    }

    if (fileExtension.toLowerCase() == "pdf") {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MyPdfViewer(fullPath, fileName)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewer(fullPath, fileName),
        ),
      );
    }
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

  Widget viewableTravelUpdates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        travelUpdatesHeading(),
        Text('Travel updates Viewable'),
      ],
    );
  }
}
