import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  final _uploadDocumentFormKey = GlobalKey<FormState>();
  bool fileUploadingInProgress = false;
  bool uploadDocumentsFilled = false;
  List<DocumentMetadata> uploadedDocuments = new List();

  DateTime arrivalDateTime;

  TextEditingController budgetController = new TextEditingController();
  FocusNode budgetFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
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
          TextFormField(
            controller: budgetController,
            focusNode: budgetFocus,
            style: TextStyle(color: Colors.blue),
            validator: validateName,
            decoration: InputDecoration(
              hintText: 'Budget for accomodation*',
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
          showPassportPages(),
          SizedBox(height: 6),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'TRAVEL UPDATES:',
          style: addPatientHeadingStyle(),
        ),
        SizedBox(height: 6),
        accoAssistWidgets,
        SizedBox(height: 12),
        travelAssistWidgets,
        SizedBox(height: 6),
      ],
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

  Widget showPassportPages() {
    Widget addDocument = SizedBox();
    if (widget.isEditable) {
      addDocument = Form(
        key: _uploadDocumentFormKey,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Upload Passport',
                style: goldenHeadingStyle(),
              ),
            ),
            SizedBox(width: 10),
            RaisedButton.icon(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0)),
              color: primary,
              icon: Icon(
                Icons.file_upload,
                color: Colors.white,
              ),
              label: Text(
                "Choose File",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: _chooseFileClicked,
            ),
          ],
        ),
      );
    }

    Widget listView = Center(child: CircularProgressIndicator());
    if (uploadedDocuments.length > 0) {
      listView = ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: uploadedDocuments.length,
        itemBuilder: (BuildContext ctxt, int index) {
          DocumentMetadata uploadedDocument = uploadedDocuments[index];
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
        },
      );
    } else {
      listView = Center(
        child: Text(
          'No passport found',
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

  _chooseFileClicked() async {
    if (!_uploadDocumentFormKey.currentState.validate()) {
      return;
    }
    setState(() {
      fileUploadingInProgress = true;
    });
    widget.scaffoldKey.currentState.showSnackBar(uploadingDocumentSnackbar());
    File file = await FilePicker.getFile();
    print('File picked');
    if (file == null || !await isFileValid(file, context)) {
      widget.scaffoldKey.currentState.hideCurrentSnackBar();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt(USER_ID).toString();
    var fileName = path.basename(file.path);
    FormData formData = new FormData.fromMap({
      "apiKey": API_KEY,
      "userId": userId,
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
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
    uploadedDocuments.add(
      new DocumentMetadata(
          statusMsg.referenceId, 'PASSPORT', fileName, file.path),
    );
    widget.scaffoldKey.currentState.hideCurrentSnackBar();
    widget.scaffoldKey.currentState
        .showSnackBar(showSnackbarWithCheck("File uploaded"));
    setState(() {
      fileUploadingInProgress = false;
    });
    setState(() {});
  }

  Widget viewableTravelUpdates() {
    return Text('Viewable');
  }
}
