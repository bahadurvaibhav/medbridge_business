import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /*GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
    ],
  );*/

  Future<void> _handleSignIn() async {
    /*try {
      print('Google sign in clicked');
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      print('Google sign in successful');
    } catch (error) {
      print(error);
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('Login Page'),
        automaticallyImplyLeading: false,
      ),
      body: Material(
        child: Column(
          children: <Widget>[
            Center(
              child: Text('Hello World'),
            ),
            FlatButton(
              onPressed: _handleSignIn,
              child: Text('Google Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
