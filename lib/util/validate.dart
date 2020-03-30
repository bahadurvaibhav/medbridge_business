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
  if (!isNumeric(name)) {
    return "Only numbers allowed";
  }
  return null;
}

bool isNumeric(String s) {
  RegExp regExp = RegExp('[0-9]');
  return regExp.hasMatch(s);
}

String validateEmail(String email) {
  if (email.length == 0) {
    return "Enter email";
  }
  RegExp specialCharacters = new RegExp(r'(?=.*?[@])');
  if (!specialCharacters.hasMatch(email)) {
    return "Email should have @";
  }
  return null;
}
