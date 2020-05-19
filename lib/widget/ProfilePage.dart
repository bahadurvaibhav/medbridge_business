import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medbridge_business/gateway/ApiUrlConstants.dart';
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
                    FocusScope.of(context).requestFocus(mobileFocus);
                  },
                  style: TextStyle(color: Colors.blue),
                  validator: validateEmail,
                  decoration: InputDecoration(
                    hintText: 'Email*',
                  ),
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
                  validator: validateEmail,
                  decoration: InputDecoration(
                    hintText: 'Mobile',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  textInputAction: TextInputAction.next,
                  focusNode: addressFocus,
                  onFieldSubmitted: (term) {
                    addressFocus.unfocus();
                    FocusScope.of(context).requestFocus(countryFocus);
                  },
                  style: TextStyle(color: Colors.blue),
                  validator: validateEmail,
                  decoration: InputDecoration(
                    hintText: 'Address',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: countryController,
                  focusNode: countryFocus,
                  style: TextStyle(color: Colors.blue),
                  validator: validateEmail,
                  decoration: InputDecoration(
                    hintText: 'Country',
                  ),
                ),
                SizedBox(height: 10),
                showRewardPercentage(rewardPercentageController.text),
              ],
            ),
          ),
        ],
      ),
    );
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
      nameController.text = user.name;
      emailController.text = user.email;
      mobileController.text = user.mobile;
      addressController.text = user.address;
      countryController.text = user.country;
      rewardPercentageController.text = user.rewardPercentage;
      setState(() {
        getProfileApiCalled = true;
      });
    }
  }

  Widget showRewardPercentage(String rewardPercentage) {
    Widget widget = new SizedBox();
    if (rewardPercentage.isNotEmpty) {
      widget = TextFormField(
        enabled: false,
        controller: rewardPercentageController,
        focusNode: rewardPercentageFocus,
        style: TextStyle(color: Colors.blue),
        validator: validateEmail,
        decoration: InputDecoration(
          hintText: 'Reward Percentage',
        ),
      );
    }
    return widget;
  }
}
