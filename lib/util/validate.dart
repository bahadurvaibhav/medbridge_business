String validateName(String name) {
  if (name.isEmpty) {
    return "Enter value";
  }
  return null;
}

String validateNumber(String name) {
  if (name.isEmpty) {
    return "Enter value";
  }
  if (isNumeric(name)) {
    return "Enter value";
  }
  return null;
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.parse(s, (e) => null) != null;
}
