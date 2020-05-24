import 'package:flutter/material.dart';

SnackBar showSnackbarWithCheck(String text) {
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
        new Text(text),
      ],
    ),
  );
}

SnackBar showSnackbarWith(String text) {
  return new SnackBar(
    content: new Row(
      children: <Widget>[new Text(text)],
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
