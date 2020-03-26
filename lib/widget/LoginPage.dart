import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Material(
        child: Column(
          children: <Widget>[
            Center(
              child: Text('Hello World'),
            ),
          ],
        ),
      ),
    );
  }
}
