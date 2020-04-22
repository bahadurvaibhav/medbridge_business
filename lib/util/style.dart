import 'package:flutter/material.dart';
import 'package:medbridge_business/util/Colors.dart';

TextStyle addPatientTitleStyle() {
  return TextStyle(
    color: primary,
    fontSize: 24,
    letterSpacing: 0.7,
  );
}

TextStyle addPatientHeadingStyle() {
  return TextStyle(
    color: golden,
    fontSize: 18,
    letterSpacing: 0.7,
  );
}

TextStyle patientNameStyle() {
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
  );
}

TextStyle goldenHeadingStyle() {
  return TextStyle(
    fontSize: 16,
    color: golden,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
  );
}

TextStyle goldenStyle() {
  return TextStyle(
    color: golden,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.7,
  );
}

TextStyle statusStyle() {
  return TextStyle(
    fontSize: 18,
    letterSpacing: 0.7,
  );
}
