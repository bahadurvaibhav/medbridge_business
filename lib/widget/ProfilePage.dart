import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:medbridge_business/gateway/ApiUrlConstants.dart';
import 'package:medbridge_business/gateway/StatusMsg.dart';
import 'package:medbridge_business/gateway/UserResponse.dart';
import 'package:medbridge_business/gateway/gateway.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/util/validate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _profileFormKey = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  FocusNode nameFocus = FocusNode();
  TextEditingController emailController = new TextEditingController();
  FocusNode emailFocus = FocusNode();
  TextEditingController mobileController = new TextEditingController();
  FocusNode mobileFocus = FocusNode();
  TextEditingController addressController = new TextEditingController();
  FocusNode addressFocus = FocusNode();
  TextEditingController countryController = new TextEditingController();
  FocusNode countryFocus = FocusNode();
  TextEditingController rewardPercentageController =
      new TextEditingController();
  FocusNode rewardPercentageFocus = FocusNode();
  User user;
  bool getProfileApiCalled = false;
  String countryInitialValue = 'IN';
  String selectedCountry = "";
  String selectedPhoneCode = "";

  @override
  void initState() {
    getProfile();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    nameFocus.dispose();
    emailController.dispose();
    emailFocus.dispose();
    mobileController.dispose();
    mobileFocus.dispose();
    addressController.dispose();
    addressFocus.dispose();
    countryController.dispose();
    countryFocus.dispose();
    rewardPercentageController.dispose();
    rewardPercentageFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!getProfileApiCalled) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitChasingDots(color: primary),
          SizedBox(height: 10),
          Text(
            'Loading...',
            style: TextStyle(
              color: primary,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.person_pin,
            size: 150,
          ),
          SizedBox(height: 30),
          Form(
            key: _profileFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  focusNode: nameFocus,
                  onFieldSubmitted: (term) {
                    nameFocus.unfocus();
                    FocusScope.of(context).requestFocus(emailFocus);
                  },
                  style: TextStyle(color: Colors.blue),
                  validator: validateName,
                  decoration: InputDecoration(
                    hintText: 'Name*',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  focusNode: emailFocus,
                  onFieldSubmitted: (term) {
                    emailFocus.unfocus();
                    FocusScope.of(context).requestFocus(countryFocus);
                  },
                  style: TextStyle(color: Colors.blue),
                  validator: validateEmail,
                  decoration: InputDecoration(
                    hintText: 'Email*',
                  ),
                ),
                SizedBox(height: 15),
                selectGender(),
                SizedBox(height: 10),
                TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: countryController,
                    textInputAction: TextInputAction.next,
                    focusNode: countryFocus,
                    style: TextStyle(color: Colors.blue),
                    decoration: InputDecoration(hintText: 'Country'),
                    onSubmitted: (term) {
                      countryFocus.unfocus();
                      FocusScope.of(context).requestFocus(mobileFocus);
                    },
                  ),
                  suggestionsCallback: (pattern) {
                    List<Country> filteredCountries = new List();
                    countryList.forEach((country) {
                      if (country.name
                          .toLowerCase()
                          .contains(pattern.toLowerCase())) {
                        filteredCountries.add(country);
                      }
                    });
                    return filteredCountries;
                  },
                  itemBuilder: (context, Country suggestion) {
                    return ListTile(
                      title: Row(
                        children: <Widget>[
                          CountryPickerUtils.getDefaultFlagImage(suggestion),
                          SizedBox(
                            width: 8.0,
                          ),
                          Text(suggestion.name),
                          Text(" ( +" + suggestion.phoneCode + " )"),
                        ],
                      ),
                    );
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  onSuggestionSelected: (Country suggestion) {
                    selectedCountry = suggestion.name;
                    selectedPhoneCode = suggestion.phoneCode;
                    countryController.text =
                        selectedCountry + " ( +" + selectedPhoneCode + " )";
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: mobileController,
                  textInputAction: TextInputAction.next,
                  focusNode: mobileFocus,
                  onFieldSubmitted: (term) {
                    mobileFocus.unfocus();
                    FocusScope.of(context).requestFocus(addressFocus);
                  },
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    hintText: 'Mobile',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  textInputAction: TextInputAction.next,
                  focusNode: addressFocus,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    hintText: 'Address',
                  ),
                ),
                SizedBox(height: 20),
                showRewardPercentage(),
                SizedBox(height: 20),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: primary,
                  child: Container(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Update Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 24,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  onPressed: updateProfileClicked,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String genderRadioValue = "";

  Widget selectGender() {
    return Row(
      children: <Widget>[
        new Radio(
          value: "Male",
          groupValue: genderRadioValue,
          onChanged: genderRadioChanged,
        ),
        new Text(
          'Male',
          style: new TextStyle(fontSize: 16.0),
        ),
        new Radio(
          value: "Female",
          groupValue: genderRadioValue,
          onChanged: genderRadioChanged,
        ),
        new Text(
          'Female',
          style: new TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  genderRadioChanged(String value) {
    setState(() {
      genderRadioValue = value;
    });
  }

  updateProfileClicked() async {
    if (!_profileFormKey.currentState.validate()) {
      print('Profile Form invalid');
      return;
    }
    print('Profile Form is valid');
    final prefs = await SharedPreferences.getInstance();
    int addedBy = prefs.getInt(USER_ID);
    var body = {
      "apiKey": API_KEY,
      "userId": addedBy.toString(),
      "name": nameController.text,
      "email": emailController.text,
      "mobile": mobileController.text,
      "gender": genderRadioValue,
      "address": addressController.text,
      "country": selectedCountry,
      "countryPhoneCode": selectedPhoneCode,
    };
    final response = await post(UPDATE_PROFILE_URL, body);
    StatusMsg responseBody = responseFromJson(response.body);
    if (responseBody.status == 200) {
      print('UpdateProfile API successful');
    } else {
      print('UpdateProfile API failure');
    }
  }

  getProfile() async {
    print("getProfile API called");
    final prefs = await SharedPreferences.getInstance();
    int addedBy = prefs.getInt(USER_ID);
    var body = {
      "apiKey": API_KEY,
      "userId": addedBy.toString(),
    };
    final response = await post(GET_PROFILE_URL, body);
    UserResponse stats = userResponseFromJson(response.body);
    if (stats.response.status == 200) {
      print('getProfile API successful');
      User user = stats.user;
      print(user.toString());
      nameController.text = user.name;
      emailController.text = user.email;
      mobileController.text = user.mobile;
      addressController.text = user.address;
      selectedCountry = user.country;
      selectedPhoneCode = user.countryPhoneCode;
      genderRadioValue = user.gender;
      countryController.text =
          selectedCountry + " ( +" + selectedPhoneCode + " )";
      rewardPercentageController.text = user.rewardPercentage;
      setState(() {
        getProfileApiCalled = true;
      });
    }
  }

  Widget showRewardPercentage() {
    Widget widget = new SizedBox();
    if (rewardPercentageController.text.isNotEmpty) {
      widget = Row(
        children: <Widget>[
          Text(
            'Reward Percentage: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(rewardPercentageController.text),
          Text('% (for each treatment completed)'),
        ],
      );
    }
    return widget;
  }
}
