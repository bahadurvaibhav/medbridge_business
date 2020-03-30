import 'dart:io';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:medbridge_business/gateway/HospitalResponse.dart';
import 'package:medbridge_business/gateway/ResponseWithId.dart';
import 'package:medbridge_business/gateway/gateway.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/constants.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/util/style.dart';
import 'package:medbridge_business/util/validate.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class AddPatientPage extends StatefulWidget {
  @override
  _AddPatientPageState createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  bool documentUploading = false;
  List<DocumentMetadata> uploadedDocuments = new List();
  TextEditingController fileDescriptionController = new TextEditingController();
  FocusNode fileDescriptionFocus = FocusNode();
  String description = "";
  final _uploadDocumentFormKey = GlobalKey<FormState>();

  TextEditingController patientNameController = new TextEditingController();
  FocusNode patientNameFocus = FocusNode();
  TextEditingController patientPhoneController = new TextEditingController();
  FocusNode patientPhoneFocus = FocusNode();
  TextEditingController patientEmailController = new TextEditingController();
  FocusNode patientEmailFocus = FocusNode();
  TextEditingController patientProblemController = new TextEditingController();
  FocusNode patientProblemFocus = FocusNode();
  TextEditingController patientPreferredDestinationController =
      new TextEditingController();
  FocusNode patientPreferredDestinationFocus = FocusNode();
  TextEditingController patientTravelAssistController =
      new TextEditingController();
  FocusNode patientTravelAssistFocus = FocusNode();
  TextEditingController patientAccommodationAssistController =
      new TextEditingController();
  FocusNode patientAccommodationAssistFocus = FocusNode();
  TextEditingController hospitalTypeAheadController =
      new TextEditingController();
  FocusNode hospitalTypeAheadFocus = FocusNode();

  String patientPhoneCode = "+91";
  String patientCountry = "India";

  List<HospitalResponse> hospitals = new List();
  List<HospitalResponse> selectedHospitals = new List();

  @override
  void initState() {
    getHospitals();
    super.initState();
  }

  getHospitals() async {
    var body = {
      "apiKey": API_KEY,
    };
    final response = await post(GET_HOSPITALS_URL, body);
    hospitals = hospitalResponseFromJson(response.body);
  }

  @override
  void dispose() {
    fileDescriptionController.dispose();
    fileDescriptionFocus.dispose();
    patientNameController.dispose();
    patientNameFocus.dispose();
    patientPhoneController.dispose();
    patientPhoneFocus.dispose();
    patientEmailController.dispose();
    patientEmailFocus.dispose();
    patientProblemController.dispose();
    patientProblemFocus.dispose();
    patientPreferredDestinationController.dispose();
    patientPreferredDestinationFocus.dispose();
    patientTravelAssistController.dispose();
    patientTravelAssistFocus.dispose();
    patientAccommodationAssistController.dispose();
    patientAccommodationAssistFocus.dispose();
    hospitalTypeAheadController.dispose();
    hospitalTypeAheadFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  patientDetails(),
                  divider(),
                  patientProblemDetails(),
                  divider(),
                  reports(),
                  divider(),
                  submitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  submitClicked() {}

  Widget submitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            color: primary,
            child: Text(
              "Submit",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 0.7,
              ),
            ),
            onPressed: submitClicked,
          ),
        ),
      ],
    );
  }

  Widget patientProblemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'PREFERENCES:',
          style: addPatientHeadingStyle(),
        ),
        TextFormField(
          controller: patientProblemController,
          textInputAction: TextInputAction.next,
          focusNode: patientProblemFocus,
          onFieldSubmitted: (term) {
            patientProblemFocus.unfocus();
            FocusScope.of(context)
                .requestFocus(patientPreferredDestinationFocus);
          },
          style: TextStyle(color: Colors.blue),
          validator: validateName,
          decoration: InputDecoration(
            hintText: 'Describe problem',
          ),
        ),
        TextFormField(
          controller: patientPreferredDestinationController,
          textInputAction: TextInputAction.next,
          focusNode: patientPreferredDestinationFocus,
          onFieldSubmitted: (term) {
            patientPreferredDestinationFocus.unfocus();
            FocusScope.of(context).requestFocus(hospitalTypeAheadFocus);
          },
          style: TextStyle(color: Colors.blue),
          validator: validateName,
          decoration: InputDecoration(
            hintText: 'Preferred destination(s) for treatment',
          ),
        ),
        selectHospitals(),
        TextFormField(
          controller: patientTravelAssistController,
          textInputAction: TextInputAction.next,
          focusNode: patientTravelAssistFocus,
          onFieldSubmitted: (term) {
            patientTravelAssistFocus.unfocus();
            FocusScope.of(context)
                .requestFocus(patientAccommodationAssistFocus);
          },
          style: TextStyle(color: Colors.blue),
          validator: validateName,
          decoration: InputDecoration(
            hintText: 'Patient needs travel assistance',
          ),
        ),
        TextFormField(
          controller: patientAccommodationAssistController,
          textInputAction: TextInputAction.next,
          focusNode: patientAccommodationAssistFocus,
          onFieldSubmitted: (term) {
            patientAccommodationAssistFocus.unfocus();
            FocusScope.of(context).requestFocus(fileDescriptionFocus);
          },
          style: TextStyle(color: Colors.blue),
          validator: validateName,
          decoration: InputDecoration(
            hintText: 'Patient needs accomodation assistance',
          ),
        ),
      ],
    );
  }

  Widget selectHospitals() {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: hospitalTypeAheadController,
        focusNode: hospitalTypeAheadFocus,
        decoration: InputDecoration(labelText: 'Preferred hospital'),
        onSubmitted: (term) {
          hospitalTypeAheadFocus.unfocus();
          FocusScope.of(context).requestFocus(patientTravelAssistFocus);
        },
      ),
      suggestionsCallback: (pattern) {
        List<HospitalResponse> filteredHospitals = new List();
        hospitals.forEach((hospital) {
          if (hospital.hospitalName.contains(pattern)) {
            filteredHospitals.add(hospital);
          }
        });
        return filteredHospitals;
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion.hospitalName),
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (suggestion) {
        hospitalTypeAheadController.text = suggestion.hospitalName;
      },
      /*onSaved: (value) => this._selectedCity = value,*/
    );
  }

  Widget patientDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Patient Details',
          style: addPatientTitleStyle(),
        ),
        TextFormField(
          controller: patientNameController,
          textInputAction: TextInputAction.next,
          focusNode: patientNameFocus,
          onFieldSubmitted: (term) {
            patientNameFocus.unfocus();
            FocusScope.of(context).requestFocus(patientPhoneFocus);
          },
          style: TextStyle(color: Colors.blue),
          validator: validateName,
          decoration: InputDecoration(
            hintText: 'Enter patient name',
          ),
        ),
        Row(
          children: <Widget>[
            CountryPickerDropdown(
              initialValue: 'IN',
              itemBuilder: _buildCountryPhoneCodeDropdownItem,
              sortComparator: (Country a, Country b) =>
                  a.phoneCode.compareTo(b.phoneCode),
              onValuePicked: (Country country) {
                patientPhoneCode = country.phoneCode;
              },
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: patientPhoneController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: patientPhoneFocus,
                onFieldSubmitted: (term) {
                  patientPhoneFocus.unfocus();
                  FocusScope.of(context).requestFocus(patientEmailFocus);
                },
                style: TextStyle(color: Colors.blue),
                validator: validateNumber,
                decoration: InputDecoration(
                  hintText: 'Enter patient phone number',
                ),
              ),
            ),
          ],
        ),
        TextFormField(
          controller: patientEmailController,
          textInputAction: TextInputAction.next,
          focusNode: patientEmailFocus,
          onFieldSubmitted: (term) {
            patientEmailFocus.unfocus();
            FocusScope.of(context).requestFocus(patientProblemFocus);
          },
          style: TextStyle(color: Colors.blue),
          validator: validateName,
          decoration: InputDecoration(
            hintText: 'Enter patient email',
          ),
        ),
        SizedBox(
          height: 20,
        ),
        CountryPickerDropdown(
          initialValue: 'IN',
          itemBuilder: _buildCountryDropdownItem,
          sortComparator: (Country a, Country b) =>
              a.isoCode.compareTo(b.isoCode),
          onValuePicked: (Country country) {
            patientCountry = country.name;
          },
        ),
      ],
    );
  }

  Widget _buildCountryDropdownItem(Country country) => Container(
        width: MediaQuery.of(context).size.width - 64,
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 15.0,
            ),
            Expanded(
              child: Text(
                country.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );

  Widget _buildCountryPhoneCodeDropdownItem(Country country) =>
      Text('+ ${country.phoneCode}');

  Widget divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Divider(
        color: golden,
        thickness: 1.0,
      ),
    );
  }

  Widget reports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'REPORTS:',
          style: addPatientHeadingStyle(),
        ),
        Form(
          key: _uploadDocumentFormKey,
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  controller: fileDescriptionController,
                  textInputAction: TextInputAction.done,
                  focusNode: fileDescriptionFocus,
                  onFieldSubmitted: (term) {
                    fileDescriptionFocus.unfocus();
                  },
                  decoration:
                      new InputDecoration(hintText: 'Enter description'),
                  validator: validateName,
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
        ),
        SizedBox(
          height: 20,
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: uploadedDocuments.length,
          itemBuilder: (BuildContext ctxt, int index) {
            DocumentMetadata uploadedDocument = uploadedDocuments[index];
            return Row(
              children: <Widget>[
                Expanded(child: Text(uploadedDocument.description)),
                SizedBox(width: 15),
                Expanded(
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
              ],
            );
          },
        ),
      ],
    );
  }

  _chooseFileClicked() async {
    if (!_uploadDocumentFormKey.currentState.validate()) {
      return;
    }
    description = fileDescriptionController.text;
    _scaffoldKey.currentState.showSnackBar(uploadingDocumentSnackbar());
    File file = await FilePicker.getFile();
    print('File picked');
    fileDescriptionController.text = description;
    if (file == null || !await isFileValid(file)) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt(USER_ID).toString();
    var fileName = path.basename(file.path);
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(file, fileName),
      "apiKey": API_KEY,
      "userId": userId,
    });
    Response response = await Dio().post(UPLOAD_DOCUMENT_URL, data: formData);
    ResponseWithId statusMsg = responseWithIdFromJson(response.data);
    if (statusMsg.response.status == 203) {
      // Unable to upload due to database or upload error
    } else if (statusMsg.response.status == 202) {
      // File extension not allowed
      showDocumentErrorDialog(
          DOCUMENT_INVALID_EXTENSION_TITLE,
          DOCUMENT_INVALID_EXTENSION_SUBTITLE +
              ALLOWED_DOCUMENT_EXTENSIONS.toString());
    } else if (statusMsg.response.status == 201) {
      // File bigger than limit
      showDocumentErrorDialog(DOCUMENT_MAX_SIZE_EXCEEDED_TITLE,
          DOCUMENT_MAX_SIZE_EXCEEDED_SUBTITLE);
    }
    print("File upload response: $response");
    String fileDescription = fileDescriptionController.text;
    uploadedDocuments.add(
      new DocumentMetadata(statusMsg.referenceId, fileDescription, fileName),
    );
    fileDescriptionController.text = "";
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(fileUploadedSnackbar());
    setState(() {});
  }

  SnackBar fileUploadedSnackbar() {
    return new SnackBar(
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
    );
  }

  SnackBar uploadingDocumentSnackbar() {
    return new SnackBar(
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          SizedBox(width: 10),
          new Text("Uploading Document...")
        ],
      ),
    );
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

class DocumentMetadata {
  int documentId;
  String description;
  String fileName;

  DocumentMetadata(this.documentId, this.description, this.fileName);
}
