import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medbridge_business/domain/DocumentMetadata.dart';
import 'package:medbridge_business/gateway/document/DocumentConstants.dart';
import 'package:medbridge_business/widget/ImageViewer.dart';
import 'package:medbridge_business/widget/PdfViewer.dart';
import 'package:path/path.dart' as path;

Future<void> viewFile(
  BuildContext context,
  DocumentMetadata uploadedDocument,
  String fullPath,
) async {
  String fileName = uploadedDocument.fileName;
  String storedFileName = uploadedDocument.storedDocumentName;
  String fileExtension =
      storedFileName.substring(storedFileName.lastIndexOf(".") + 1);
  print('File extension: ' + fileExtension);
  if (fileExtension.toLowerCase() == "pdf") {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyPdfViewer(fullPath, fileName)),
    );
  } else if (fileExtension.toLowerCase() == "doc" ||
      fileExtension.toLowerCase() == "docx") {
    await showWordDocument(fullPath);
  } else {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewer(fullPath, fileName),
      ),
    );
  }
}

Future<void> showWordDocument(String fullPath) async {
  File file = new File(fullPath);
  Uint8List bytes = file.readAsBytesSync();
  final ByteData byteData = ByteData.view(bytes.buffer);
  await Share.file(
    'Info_for_Visa',
    'Info_for_Visa.doc',
    byteData.buffer.asUint8List(),
    'application/msword',
  );
}

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
