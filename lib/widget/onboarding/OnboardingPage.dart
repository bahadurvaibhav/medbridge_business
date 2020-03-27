import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:medbridge_business/gateway/FacebookLoginResponse.dart';
import 'package:medbridge_business/gateway/ResponseWithId.dart';
import 'package:medbridge_business/gateway/gateway.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/widget/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroItem {
  final String title;
  final String subtitle;
  final String image1;
  final String image2;

  IntroItem({this.title, this.subtitle, this.image1, this.image2});
}

final List<IntroItem> introItems = [
  IntroItem(
      image1: "images/onboarding1.jpg",
      image2: "images/onboarding2.jpg",
      title: "Connect with Doctors around the world.",
      subtitle: "Send us a query and get a customised solution."),
  IntroItem(
      image1: "images/onboarding3.jpg",
      image2: "images/onboarding4.jpg",
      title: "Live your life smarter and better with us.",
      subtitle:
          "Get personalised quality care assistance with periodic follow ups."),
];

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentIndex;
  final SwiperController _controller = SwiperController();

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );
  final facebookLogin = FacebookLogin();

  _signInGoogle() async {
    try {
      print('Google sign in clicked');
      GoogleSignInAccount profile = await _googleSignIn.signIn();
      print('Google sign in successful');
      register(profile.displayName, profile.email, profile.id, "", context);
    } catch (error) {
      print(error);
    }
  }

  _signInFacebook() async {
    print('Facebook sign in clicked');
    final result = await facebookLogin.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        print('Facebook sign in successful');
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,picture,email&access_token=${token}');
        FacebookLoginResponse profile =
            facebookLoginResponseFromJson(graphResponse.body);
        print(profile);
        register(profile.name, profile.email, "", profile.id, context);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Facebook sign in cancelledByUser');
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(IS_LOGGED_IN, false);
        break;
      case FacebookLoginStatus.error:
        print('Facebook sign in error');
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(IS_LOGGED_IN, false);
        break;
    }
  }

  register(String name, String email, String googleId, String facebookId,
      BuildContext context) async {
    var body = {
      "name": name,
      "email": email,
      "googleId": googleId,
      "facebookId": facebookId,
    };
    final response = await post(
        'http://connectinghealthcare.in/api/business/register.php', body);
    var loginResponse = responseWithIdFromJson(response.body);
    if (loginResponse.response.status == 200) {
      print("Register API successful");
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(NAME, name);
      prefs.setString(EMAIL, email);
      prefs.setString(GOOGLE_ID, googleId);
      prefs.setString(FACEBOOK_ID, facebookId);
      prefs.setBool(IS_LOGGED_IN, true);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (loginResponse.response.status == 203) {
      print("Register API failure");
    }
  }

  _logoutFacebook() async {
    facebookLogin.logOut();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(IS_LOGGED_IN, false);
  }

  @override
  void initState() {
    currentIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Swiper(
              controller: _controller,
              itemCount: introItems.length,
              autoplay: false,
              autoplayDelay: 5000,
              index: currentIndex,
              onIndexChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (context, index) => _buildPage(context, index),
              pagination: SwiperPagination(
                  builder: DotSwiperPaginationBuilder(
                      activeColor: primary,
                      color: primary,
                      size: 5.0,
                      activeSize: 12.0)),
              loop: true,
              autoplayDisableOnInteraction: true,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0)),
                color: Colors.red,
                icon: Icon(
                  FontAwesomeIcons.google,
                  color: Colors.white,
                ),
                label: Text(
                  "Google",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _signInGoogle();
                },
              ),
              SizedBox(width: 10.0),
              RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2.0)),
                color: Colors.indigo,
                icon: Icon(
                  FontAwesomeIcons.facebook,
                  color: Colors.white,
                ),
                label: Text(
                  "Facebook",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _signInFacebook();
                },
              ),
            ],
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 60.0),
          Text(
            introItems[index].title,
            style: TextStyle(
                color: Color(0xFF0271B8),
                fontSize: 30.0,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          Text(
            introItems[index].subtitle,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 2 - 30,
                  child: Image.asset(
                    introItems[index].image1,
                    fit: BoxFit.scaleDown,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2 - 30,
                  child: Image.asset(
                    introItems[index].image2,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          //image
        ],
      ),
    );
  }
}
