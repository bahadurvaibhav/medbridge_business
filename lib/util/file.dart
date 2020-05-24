import 'dart:io';

import 'package:flutter/material.dart';
import 'package:medbridge_business/gateway/document/DocumentConstants.dart';
import 'package:path/path.dart' as path;

Future<bool> isFileValid(File file, BuildContext context) async {
  String fileExtension = path.extension(file.path);
  if (!ALLOWED_DOCUMENT_EXTENSIONS.contains(fileExtension.toLowerCase())) {
    // File not valid extension
    showDocumentErrorDialog(
      context,
      DOCUMENT_INVALID_EXTENSION_TITLE,
      DOCUMENT_INVALID_EXTENSION_SUBTITLE +
          ALLOWED_DOCUMENT_EXTENSIONS.toString(),
    );
    return false;
  }
  int fileSize = await file.length();
  if (fileSize > DOCUMENT_MAX_SIZE * 1000000) {
    // File bigger than limit
    showDocumentErrorDialog(
      context,
      DOCUMENT_MAX_SIZE_EXCEEDED_TITLE,
      DOCUMENT_MAX_SIZE_EXCEEDED_SUBTITLE,
    );
    return false;
  }
  return true;
}

showDocumentErrorDialog(BuildContext context, String title, String subtitle) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: <Widget>[
        FlatButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('Close'),
        ),
      ],
    ),
  );
}
