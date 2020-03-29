import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/constants.dart';
import 'package:http/http.dart' as http;
import 'package:medbridge_business/util/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Google",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                File file = await FilePicker.getFile();
                print('File picked');
                http.MultipartRequest request = http.MultipartRequest(
                  'POST',
                  Uri.parse(UPLOAD_DOCUMENT_URL),
                );
                print('URL: ' + UPLOAD_DOCUMENT_URL);
                request.files.add(
                  http.MultipartFile(
                    'document',
                    file.readAsBytes().asStream(),
                    file.lengthSync(),
                    filename: 'test',
                  ),
                );
                request.fields['apiKey'] = API_KEY;
                final prefs = await SharedPreferences.getInstance();
                var userId = prefs.getInt(USER_ID).toString();
                request.fields['userId'] = userId;
                print('apiKey: ' + API_KEY + '; userId: ' + userId);
                var response = await request.send();
                print('File sent');
              },
            ),
          ],
        ),
      ),
    );
  }
}
