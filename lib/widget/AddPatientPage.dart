import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:medbridge_business/gateway/Response.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/constants.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  bool documentUploading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Row(
            children: <Widget>[
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
        ),
      ),
    );
  }

  _chooseFileClicked() async {
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            SizedBox(width: 10),
            new Text("Uploading Document...")
          ],
        ),
      ),
    );
    File file = await FilePicker.getFile();
    print('File picked');
    if (!await isFileValid(file)) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt(USER_ID).toString();
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(file, path.basename(file.path)),
      "apiKey": API_KEY,
      "userId": userId,
    });
    Response response = await Dio().post(UPLOAD_DOCUMENT_URL, data: formData);
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        duration: new Duration(seconds: 4),
        content: new Row(
          children: <Widget>[
            Icon(
              Icons.check,
              color: Colors.blue,
              size: 40,
            ),
            SizedBox(width: 10),
            new Text("File uploaded")
          ],
        ),
      ),
    );
    StatusMsg statusMsg = responseFromJson(response.data);
    if (statusMsg.status == 203) {
      // Unable to upload due to database or upload error
    } else if (statusMsg.status == 202) {
      // File extension not allowed
      showDocumentErrorDialog(
          DOCUMENT_INVALID_EXTENSION_TITLE,
          DOCUMENT_INVALID_EXTENSION_SUBTITLE +
              ALLOWED_DOCUMENT_EXTENSIONS.toString());
    } else if (statusMsg.status == 201) {
      // File bigger than limit
      showDocumentErrorDialog(DOCUMENT_MAX_SIZE_EXCEEDED_TITLE,
          DOCUMENT_MAX_SIZE_EXCEEDED_SUBTITLE);
    }
    print("File upload response: $response");
  }

  Future<bool> isFileValid(File file) async {
    String fileExtension = path.extension(file.path);
    if (!ALLOWED_DOCUMENT_EXTENSIONS.contains(fileExtension.toLowerCase())) {
      // File not valid extension
      showDocumentErrorDialog(
          DOCUMENT_INVALID_EXTENSION_TITLE,
          DOCUMENT_INVALID_EXTENSION_SUBTITLE +
              ALLOWED_DOCUMENT_EXTENSIONS.toString());
      return false;
    }
    int fileSize = await file.length();
    if (fileSize > DOCUMENT_MAX_SIZE * 1000000) {
      // File bigger than limit
      showDocumentErrorDialog(DOCUMENT_MAX_SIZE_EXCEEDED_TITLE,
          DOCUMENT_MAX_SIZE_EXCEEDED_SUBTITLE);
      return false;
    }
    return true;
  }

  showDocumentErrorDialog(String title, String subtitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
