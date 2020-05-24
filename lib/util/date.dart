import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:medbridge_business/util/Colors.dart';

String getDateString(DateTime dateTime) {
  String dateString = "";
  if (dateTime != null) {
    dateString = dateTime.toIso8601String();
  }
  return dateString;
}

Widget showDate(BuildContext context, bool isEditable, DateTime dateTime,
    Function onConfirm, String hintText) {
  Function updateDate = () {};
  Widget changeText = SizedBox();
  if (isEditable) {
    changeText = Text(
      "  Change",
      style: TextStyle(
        color: primary,
        fontSize: 16.0,
      ),
    );
    updateDate = () {
      showDatePicker(context, onConfirm);
    };
  }
  return FlatButton(
    onPressed: updateDate,
    child: Container(
      alignment: Alignment.center,
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.date_range,
                      size: 18.0,
                      color: primary,
                    ),
                    SizedBox(width: 5),
                    Text(
                      getDateDisplay(dateTime, hintText),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          changeText,
        ],
      ),
    ),
    color: Colors.white,
  );
}

String getDateDisplay(DateTime date, String hintText) {
  if (date == null) {
    return hintText;
  }
  return '${date.year} - ${date.month} - ${date.day}';
}

void showDatePicker(BuildContext context, Function onConfirm) {
  DatePicker.showDatePicker(
    context,
    theme: DatePickerTheme(
      containerHeight: 210.0,
    ),
    showTitleActions: true,
    minTime: DateTime.now(),
    onConfirm: onConfirm,
    currentTime: DateTime.now(),
    locale: LocaleType.en,
  );
}
