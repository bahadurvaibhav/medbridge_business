import 'dart:io';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:medbridge_business/domain/DocumentMetadata.dart';
import 'package:medbridge_business/domain/HospitalOption.dart';
import 'package:medbridge_business/gateway/ApiUrlConstants.dart';
import 'package:medbridge_business/gateway/AutocompleteTextResponse.dart';
import 'package:medbridge_business/gateway/IdNameResponse.dart';
import 'package:medbridge_business/gateway/PatientResponse.dart';
import 'package:medbridge_business/gateway/ResponseWithId.dart';
import 'package:medbridge_business/gateway/StatusMsg.dart';
import 'package:medbridge_business/gateway/document/DocumentConstants.dart';
import 'package:medbridge_business/gateway/gateway.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/StatusConstants.dart';
import 'package:medbridge_business/util/file.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/util/snackbar.dart';
import 'package:medbridge_business/util/style.dart';
import 'package:medbridge_business/util/validate.dart';
import 'package:medbridge_business/widget/patient/HospitalOptions.dart';
import 'package:medbridge_business/widget/patient/TravelUpdates.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
final _hospitalOptionsKey = new GlobalKey<HospitalOptionsState>();

class PatientPage extends StatefulWidget {
  final PatientResponse patient;
  final Status status;

  PatientPage({
    Key key,
    this.patient,
    @required this.status,
  }) : super(key: key);

  @override
  _PatientPageState createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
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
  final _patientDetailsFormKey = GlobalKey<FormState>();
  final _patientPreferencesFormKey = GlobalKey<FormState>();

  String patientPhoneCode = "+91";
  String patientCountry = "India";

  List<IdNameResponse> hospitals = new List();
  List<IdNameResponse> selectedHospitals = new List();
  List<IdNameResponse> destinations = new List();
  List<IdNameResponse> selectedDestinations = new List();
  String selectedTravelAssistRadioValue = "";
  String selectedAccommodationAssistRadioValue = "";
  List<IdNameResponse> treatments = new List();

  String countryInitialValue = 'IN';
  TextEditingController patientCountryController = new TextEditingController();
  String selectPreferredHospitalName = "";
  String selectPreferredDestinationName = "";
  bool getHospitalsCompleted = false;
  bool uploadDocumentsFilled = false;
  bool fileUploadingInProgress = false;
  bool addPatientInProgress = false;
  bool submitSelectHospitalOptionInProgress = false;

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    getAutocompleteText(widget.patient);
    super.initState();
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
    patientCountryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget submitButton = SizedBox();
    if (widget.status == Status.NEW_PATIENT) {
      submitButton = showSubmitButton(addPatientInProgress, submitClicked);
    }
    Widget floatingActionButton = SizedBox();
    if (widget.status == Status.HOSPITAL_OPTIONS) {
      floatingActionButton = Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.keyboard_arrow_up),
            onPressed: () {
              _scrollController.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            },
          ),
          Text('Go up'),
        ],
      );
    }
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: floatingActionButton,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  showPatientDetails(),
                  divider(),
                  showStatus(),
                  showTravelUpdates(),
                  showPatientPreferencesDetails(),
                  divider(),
                  showReports(),
                  divider(),
                  submitButton,
                  showHospitalOptions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget showTravelUpdates() {
    bool isEditable = widget.status == Status.TREATMENT_CONFIRMED;
    bool inTravelFlow = isEditable ||
        widget.status == Status.TRAVEL_STATUS_UPDATE ||
        widget.status == Status.VISA_APPOINTMENT ||
        widget.status == Status.TRAVEL_STATUS_CONFIRMED;
    bool postTravelFlow = widget.status == Status.PATIENT_RECEIVED ||
        widget.status == Status.TREATMENT_ONGOING ||
        widget.status == Status.TREATMENT_COMPLETED;
    bool travelAssistIsYes = false;
    bool accoAssistIsYes = false;
    if (widget.patient != null) {
      travelAssistIsYes = widget.patient.patientTravelAssist == 'Yes';
      accoAssistIsYes = widget.patient.patientAccommodationAssist == 'Yes';
    }
    bool travelUpdatesShownByStatus = (inTravelFlow || postTravelFlow);
    bool travelOrAccoAssistSelected = (travelAssistIsYes || accoAssistIsYes);
    bool showTravelUpdates =
        travelUpdatesShownByStatus && travelOrAccoAssistSelected;
    if (!showTravelUpdates) {
      return SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TravelUpdates(
          isEditable: isEditable,
          scaffoldKey: _scaffoldKey,
          status: widget.status,
          patientId: widget.patient.id,
          travelAssistYes: travelAssistIsYes,
          accoAssistYes: accoAssistIsYes,
        ),
        divider(),
      ],
    );
  }

  Widget showStatus() {
    if (widget.status == Status.NEW_PATIENT) {
      return SizedBox();
    }
    return Column(
      children: <Widget>[
        Text(
          'STATUS: ' + statusReadable.reverse[widget.status],
          style: statusStyle(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  getAutocompleteText(PatientResponse patient) async {
    print('getAutocompleteText API called');
    var body = {
      "apiKey": API_KEY,
    };
    final response = await post(GET_AUTOCOMPLETE_TEXT_URL, body);
    print(response.body);
    AutocompleteTextResponse res =
        autocompleteTextResponseFromJson(response.body);
    hospitals = res.hospitals;
    destinations = res.destinations;
    treatments = res.treatments;
    setState(() {
      getHospitalsCompleted = true;
    });
    if (widget.status == Status.PATIENT_SUBMITTED ||
        widget.status == Status.HOSPITAL_OPTIONS ||
        widget.status == Status.TREATMENT_CONFIRMED ||
        widget.status == Status.TRAVEL_STATUS_UPDATE ||
        widget.status == Status.VISA_APPOINTMENT ||
        widget.status == Status.TRAVEL_STATUS_CONFIRMED ||
        widget.status == Status.PATIENT_RECEIVED ||
        widget.status == Status.TREATMENT_ONGOING ||
        widget.status == Status.TREATMENT_COMPLETED) {
      List<String> preferredHospitalId = patient.preferredHospitalId.split(',');
      hospitals.forEach((hospital) {
        if (preferredHospitalId.contains(hospital.id)) {
          if (selectPreferredHospitalName.isEmpty) {
            selectPreferredHospitalName = hospital.name;
          } else {
            selectPreferredHospitalName += ", " + hospital.name;
          }
        }
      });
      patient.documents.forEach((doc) {
        uploadedDocuments.add(new DocumentMetadata(
          int.parse(doc.id),
          doc.documentDescription,
          doc.documentName,
          doc.storedDocumentName,
        ));
      });
      setState(() {
        uploadDocumentsFilled = true;
      });
    }
  }

  showHospitalOptions() {
    Widget hospitalOptions = SizedBox();
    if (widget.status == Status.NEW_PATIENT) {
      hospitalOptions = SizedBox();
    } else if (widget.status == Status.PATIENT_SUBMITTED) {
    } else if (widget.status == Status.HOSPITAL_OPTIONS) {
      hospitalOptions = Column(
        children: <Widget>[
          HospitalOptions(
            key: _hospitalOptionsKey,
            patientId: widget.patient.id,
            hospitals: hospitals,
            treatments: treatments,
            editable: false,
            selectable: true,
            hospitalOptions: toHospitalOption(widget.patient.hospitalOptions),
          ),
          divider(),
          showSubmitButton(submitSelectHospitalOptionInProgress,
              submitSelectHospitalOptionClicked),
        ],
      );
    } else {
      hospitalOptions = Column(
        children: <Widget>[
          HospitalOptions(
            key: _hospitalOptionsKey,
            patientId: widget.patient.id,
            hospitals: hospitals,
            treatments: treatments,
            editable: false,
            selectable: false,
            hospitalOptions: toHospitalOption(widget.patient.hospitalOptions),
          ),
          divider(),
        ],
      );
    }
    return hospitalOptions;
  }

  submitSelectHospitalOptionClicked() async {
    print('submitSelectedHospitalOptionClicked()');
    String optionId =
        _hospitalOptionsKey.currentState.preferredHospitalOptionId;
    if (optionId == "-1") {
      print('Hospital options not selected');
      _scaffoldKey.currentState
          .showSnackBar(showSnackbarWith("Select 1 option"));
      return;
    }
    setState(() {
      submitSelectHospitalOptionInProgress = true;
    });
    var body = {
      "hospitalOptionId": optionId,
      "patientId": widget.patient.id,
      "apiKey": API_KEY,
    };
    print(body.toString());
    final response = await post(SELECT_HOSPITAL_OPTION_URL, body);
    StatusMsg statusMsg = responseFromJson(response.body);
    if (statusMsg.status == 200) {
      print('Select Hospital Option API success');
      setState(() {
        submitSelectHospitalOptionInProgress = false;
      });
      _scaffoldKey.currentState.showSnackBar(showSnackbarWithCheck(
          "Hospital options has been selected successfully"));
      Navigator.pop(context);
    } else {
      print('Select Hospital Option API failed with msg: ' + statusMsg.msg);
      setState(() {
        submitSelectHospitalOptionInProgress = false;
      });
      _scaffoldKey.currentState.showSnackBar(showSnackbarWith(
          "Unable to select hospital options. Try again later."));
    }
  }

  submitClicked() async {
    bool patientDetailsValid = _patientDetailsFormKey.currentState.validate();
    bool patientPreferencesValid =
        _patientPreferencesFormKey.currentState.validate();
    if (!patientDetailsValid || !patientPreferencesValid) {
      print('Form invalid with patient details: ' +
          patientDetailsValid.toString() +
          ' and preferences: ' +
          patientPreferencesValid.toString());
      return;
    }
    setState(() {
      addPatientInProgress = true;
    });
    String patientName = patientNameController.text;
    String patientPhone = patientPhoneCode + patientPhoneController.text;
    String patientEmail = patientEmailController.text;
    String patientProblem = patientProblemController.text;
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt(USER_ID).toString();
    String uploadedDocumentsString = documentMetadataToJson(uploadedDocuments);
    print('Uploaded Documents: ' + uploadedDocumentsString);
    var body = {
      "userId": userId.toString(),
      "patientName": patientName,
      "patientPhone": patientPhone,
      "patientEmail": patientEmail,
      "patientCountry": patientCountry,
      "patientProblem": patientProblem,
      "patientPreferredDestination":
          selectedDestinations.map((response) => response.name).join(','),
      "patientTravelAssist": selectedTravelAssistRadioValue,
      "patientAccommodationAssist": selectedAccommodationAssistRadioValue,
      "preferredHospitalId":
          selectedHospitals.map((response) => response.id).join(','),
      "uploadedDocuments": uploadedDocumentsString,
      "apiKey": API_KEY,
    };
    print(body.toString());
    final response = await post(ADD_PATIENT_URL, body);
    StatusMsg statusMsg = responseFromJson(response.body);
    if (statusMsg.status == 200) {
      print("Add Patient API successful");
      setState(() {
        addPatientInProgress = false;
      });
      Navigator.pop(context);
    } else {
      print("Add Patient API failed");
      setState(() {
        addPatientInProgress = false;
      });
    }
  }

  Widget showSubmitButton(bool inProgress, Function buttonClicked) {
    Widget text = SizedBox();
    if (inProgress) {
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

  Widget showPatientPreferencesDetails() {
    if (widget.status == Status.NEW_PATIENT) {
      return editablePatientPreferencesDetails();
    } else {
      return viewOnlyPatientPreferencesDetails();
    }
  }

  Widget viewOnlyPatientPreferencesDetails() {
    String patientPreferredDestination =
        widget.patient.patientPreferredDestination;
    if (patientPreferredDestination.isEmpty) {
      patientPreferredDestination = "-";
    }
    String hospitalName = selectPreferredHospitalName;
    if (hospitalName.isEmpty) {
      hospitalName = "-";
    }
    var patientTravelAssist = widget.patient.patientTravelAssist;
    if (patientTravelAssist.isEmpty) {
      patientTravelAssist = "-";
    }
    var patientAccommodationAssist = widget.patient.patientAccommodationAssist;
    if (patientAccommodationAssist.isEmpty) {
      patientAccommodationAssist = "-";
    }
    var spaceHeadingToValue = SizedBox(height: 8);
    var spaceToNextField = SizedBox(height: 16);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('PROBLEM:', style: goldenHeadingStyle()),
        spaceHeadingToValue,
        Text(widget.patient.patientProblem),
        spaceToNextField,
        Text('Preferred Destination for Treatment:',
            style: goldenHeadingStyle()),
        spaceHeadingToValue,
        Text(patientPreferredDestination),
        spaceToNextField,
        Text('Patient Preferred Hospital:', style: goldenHeadingStyle()),
        spaceHeadingToValue,
        Text(hospitalName),
        spaceToNextField,
        Text('Patient Needs Travel Assistance:', style: goldenHeadingStyle()),
        spaceHeadingToValue,
        Text(patientTravelAssist),
        spaceToNextField,
        Text('Patient Needs Accomodation Assistance::',
            style: goldenHeadingStyle()),
        spaceHeadingToValue,
        Text(patientAccommodationAssist),
        spaceToNextField,
      ],
    );
  }

  Widget editablePatientPreferencesDetails() {
    return Form(
      key: _patientPreferencesFormKey,
      child: Column(
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
              hintText: 'Describe problem*',
            ),
          ),
          selectDestination('Preferred destination(s) for treatment'),
          selectHospitals('Preferred hospital'),
          SizedBox(height: 10),
          Text('Does patient needs travel assistance?'),
          selectTravelAssist(),
          SizedBox(height: 10),
          Text('Does patient needs accomodation assistance?'),
          selectAccommodationAssist(),
        ],
      ),
    );
  }

  accommodationAssistRadioChanged(String value) {
    setState(() {
      selectedAccommodationAssistRadioValue = value;
    });
  }

  Widget selectAccommodationAssist() {
    return Row(
      children: <Widget>[
        new Radio(
          value: "Yes",
          groupValue: selectedAccommodationAssistRadioValue,
          onChanged: accommodationAssistRadioChanged,
        ),
        new Text(
          'Yes',
          style: new TextStyle(fontSize: 16.0),
        ),
        new Radio(
          value: "No",
          groupValue: selectedAccommodationAssistRadioValue,
          onChanged: accommodationAssistRadioChanged,
        ),
        new Text(
          'No',
          style: new TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  travelAssistRadioChanged(String value) {
    setState(() {
      selectedTravelAssistRadioValue = value;
    });
  }

  Widget selectTravelAssist() {
    return Row(
      children: <Widget>[
        new Radio(
          value: "Yes",
          groupValue: selectedTravelAssistRadioValue,
          onChanged: travelAssistRadioChanged,
        ),
        new Text(
          'Yes',
          style: new TextStyle(fontSize: 16.0),
        ),
        new Radio(
          value: "No",
          groupValue: selectedTravelAssistRadioValue,
          onChanged: travelAssistRadioChanged,
        ),
        new Text(
          'No',
          style: new TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  Widget selectDestination(String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: patientPreferredDestinationController,
            textInputAction: TextInputAction.next,
            focusNode: patientPreferredDestinationFocus,
            style: TextStyle(color: Colors.blue),
            decoration: InputDecoration(hintText: hintText),
            onSubmitted: (term) {
              patientPreferredDestinationFocus.unfocus();
              FocusScope.of(context).requestFocus(hospitalTypeAheadFocus);
            },
          ),
          suggestionsCallback: (pattern) {
            List<IdNameResponse> filteredDestinations = new List();
            destinations.forEach((destination) {
              if (destination.name.contains(pattern)) {
                filteredDestinations.add(destination);
              }
            });
            return filteredDestinations;
          },
          itemBuilder: (context, IdNameResponse suggestion) {
            return ListTile(
              title: Text(suggestion.name),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (IdNameResponse suggestion) {
            patientPreferredDestinationController.text = "";
            selectedDestinations.forEach((destination) {
              if (destination.id == suggestion.id) {
                print("Selected destination twice");
                return;
              }
            });
            selectedDestinations.add(suggestion);
          },
        ),
        new Wrap(
          spacing: 10.0,
          children: selectedDestinations
              .map((destination) => getChip(selectedDestinations, destination))
              .toList(),
        ),
      ],
    );
  }

  Widget selectHospitals(String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TypeAheadFormField(
          textFieldConfiguration: TextFieldConfiguration(
            controller: hospitalTypeAheadController,
            textInputAction: TextInputAction.next,
            focusNode: hospitalTypeAheadFocus,
            style: TextStyle(color: Colors.blue),
            decoration: InputDecoration(hintText: hintText),
            onSubmitted: (term) {
              hospitalTypeAheadFocus.unfocus();
              FocusScope.of(context).requestFocus(fileDescriptionFocus);
            },
          ),
          suggestionsCallback: (pattern) {
            List<IdNameResponse> filteredHospitals = new List();
            hospitals.forEach((hospital) {
              if (hospital.name.contains(pattern)) {
                filteredHospitals.add(hospital);
              }
            });
            return filteredHospitals;
          },
          itemBuilder: (context, IdNameResponse suggestion) {
            return ListTile(
              title: Text(suggestion.name),
            );
          },
          transitionBuilder: (context, suggestionsBox, controller) {
            return suggestionsBox;
          },
          onSuggestionSelected: (IdNameResponse suggestion) {
            hospitalTypeAheadController.text = "";
            selectedHospitals.forEach((hospital) {
              if (hospital.id == suggestion.id) {
                print("Selected destination twice");
                return;
              }
            });
            selectedHospitals.add(suggestion);
          },
        ),
        new Wrap(
          spacing: 10.0,
          children: selectedHospitals
              .map((hospital) => getChip(selectedHospitals, hospital))
              .toList(),
        ),
      ],
    );
  }

  Widget getChip(List<IdNameResponse> responses, IdNameResponse response) {
    return Chip(
      label: new Text(response.name),
      onDeleted: () {
        responses.remove(response);
        setState(() {});
      },
      labelPadding: EdgeInsets.all(2.0),
      deleteIcon: Icon(Icons.clear),
    );
  }

  Widget showPatientDetails() {
    if (widget.status == Status.NEW_PATIENT) {
      return editablePatientDetails();
    } else {
      return viewOnlyPatientDetails();
    }
  }

  Widget viewOnlyPatientDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Patient Details',
          style: addPatientTitleStyle(),
        ),
        SizedBox(height: 15),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(widget.patient.patientName, style: patientNameStyle()),
                SizedBox(height: 10),
                Text(widget.patient.patientPhone),
                SizedBox(height: 10),
                Text(widget.patient.patientEmail),
                SizedBox(height: 10),
                Text(widget.patient.patientCountry),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget editablePatientDetails() {
    return Form(
      key: _patientDetailsFormKey,
      child: Column(
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
              hintText: 'Enter patient name*',
            ),
          ),
          Row(
            children: <Widget>[
              CountryPickerDropdown(
                initialValue: countryInitialValue,
                itemBuilder: _buildCountryPhoneCodeDropdownItem,
                sortComparator: (Country a, Country b) =>
                    a.phoneCode.compareTo(b.phoneCode),
                onValuePicked: (Country country) {
                  patientPhoneCode = '+' + country.phoneCode;
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
                    hintText: 'Enter patient phone number*',
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
            validator: validateEmail,
            decoration: InputDecoration(
              hintText: 'Enter patient email*',
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
      ),
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

  Widget showReports() {
    Widget addDocument = SizedBox();
    if (widget.status == Status.NEW_PATIENT) {
      addDocument = Form(
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
                decoration: new InputDecoration(hintText: 'Enter description'),
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
      );
    }

    Widget listView = Center(child: CircularProgressIndicator());
    if (uploadDocumentsFilled || widget.status == Status.NEW_PATIENT) {
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
        listView = Center(child: Text('No reports found'));
      }
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
        Text(
          'REPORTS:',
          style: addPatientHeadingStyle(),
        ),
        addDocument,
        SizedBox(
          height: 20,
        ),
        listView,
        fileUploadingProgress,
      ],
    );
  }

  viewDocument(DocumentMetadata uploadedDocument) async {
    print('downloadDocument() clicked');

    String storedFileName = uploadedDocument.storedDocumentName;

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

    await viewFile(context, uploadedDocument, fullPath);
  }

  _chooseFileClicked() async {
    if (!_uploadDocumentFormKey.currentState.validate()) {
      return;
    }
    setState(() {
      fileUploadingInProgress = true;
    });
    description = fileDescriptionController.text;
    _scaffoldKey.currentState.showSnackBar(uploadingDocumentSnackbar());
    File file = await FilePicker.getFile();
    print('File picked');
    fileDescriptionController.text = description;
    if (file == null || !await isFileValid(file, context)) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
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
    String fileDescription = fileDescriptionController.text;
    uploadedDocuments.add(
      new DocumentMetadata(
          statusMsg.referenceId, fileDescription, fileName, file.path),
    );
    fileDescriptionController.text = "";
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState
        .showSnackBar(showSnackbarWithCheck("File uploaded"));
    setState(() {
      fileUploadingInProgress = false;
    });
    setState(() {});
  }
}
