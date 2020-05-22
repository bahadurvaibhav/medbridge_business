import 'package:flutter/material.dart';
import 'package:medbridge_business/util/StatusConstants.dart';

class TravelUpdates extends StatefulWidget {
  final bool isEditable;
  final Status status;

  TravelUpdates({
    Key key,
    @required this.isEditable,
    @required this.status,
  }) : super(key: key);

  @override
  _TravelUpdatesState createState() => _TravelUpdatesState();
}

class _TravelUpdatesState extends State<TravelUpdates> {
  @override
  Widget build(BuildContext context) {
    return Text('Travel Updates');
  }
}
