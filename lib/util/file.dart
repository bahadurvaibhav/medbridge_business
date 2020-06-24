import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medbridge_business/domain/DocumentMetadata.dart';
import 'package:medbridge_business/gateway/ApiUrlConstants.dart';
import 'package:medbridge_business/gateway/ResponseWithId.dart';
import 'package:medbridge_business/gateway/TravelStatusResponse.dart';
import 'package:medbridge_business/gateway/document/DocumentConstants.dart';
import 'package:medbridge_business/util/colors.dart';
import 'package:medbridge_business/util/preferences.dart';
import 'package:medbridge_business/util/style.dart';
import 'package:medbridge_business/widget/ImageViewer.dart';
import 'package:medbridge_business/widget/PdfViewer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

DocumentMetadata documentMetadataFrom(Document document, String description) {
  return new DocumentMetadata(
    int.tryParse(document.id),
    description,
    document.documentName,
    document.storedDocumentName,
  );
}

String getDocumentsString(List<DocumentMetadata> documents) {
  List<String> documentIds = new List();
  documents.forEach((document) {
    documentIds.add(
      document.documentId.toString(),
    );
  });
  return documentIds.join(",");
}

Widget showDocuments(
    BuildContext context,
    bool isEditable,
    String title,
    List<DocumentMetadata> documents,
    bool fileUploadingInProgress,
    Function fileClicked) {
  Widget addDocument = SizedBox();
  if (isEditable) {
    addDocument = Form(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Upload ' + title,
              style: goldenHeadingStyle(),
            ),
          ),
          SizedBox(width: 10),
          RaisedButton.icon(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
            color: primary,
            icon: Icon(
              Icons.file_upload,
              color: Colors.white,
            ),
            label: Text(
              "Choose File",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: fileClicked,
          ),
        ],
      ),
    );
  }

  Widget listView = Center(child: CircularProgressIndicator());
  if (documents.length > 0) {
    listView = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: documents.length,
      itemBuilder: (BuildContext ctxt, int index) {
        DocumentMetadata uploadedDocument = documents[index];
        return showDocument(context, isEditable, uploadedDocument);
      },
    );
  } else {
    listView = Center(
      child: Text(
        'No ' + title + ' found',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget fileUploadingProgress = SizedBox();
  if (fileUploadingInProgress) {
    fileUploadingProgress = Center(child: CircularProgressIndicator());
  } else {
    fileUploadingProgress = SizedBox();
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      addDocument,
      SizedBox(
        height: 20,
      ),
      fileUploadingProgress,
      listView,
    ],
  );
}

Widget showDocument(
    BuildContext context, bool isEditable, DocumentMetadata uploadedDocument) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(uploadedDocument.description)),
        SizedBox(width: 15),
        Expanded(
          child: GestureDetector(
            onTap: () => viewDocument(context, isEditable, uploadedDocument),
            child: Row(
              children: <Widget>[
                Icon(Icons.attach_file),
                Flexible(
                  child: Text(
                    uploadedDocument.fileName,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

viewDocument(BuildContext context, bool isEditable,
    DocumentMetadata uploadedDocument) async {
  print('downloadDocument() clicked');

  String storedFileName = uploadedDocument.storedDocumentName;

  String fullPath = "";

  if (isEditable) {
    fullPath = storedFileName;
  } else {
    var tempDir = await getTemporaryDirectory();
    fullPath = tempDir.path + "/" + storedFileName + "'";
    print('download to path ${fullPath}');

    String urlPath = DOWNLOAD_DOCUMENT_URL + storedFileName;
    print('download from ${urlPath}');
    await Dio().download(urlPath, fullPath);
  }

  await viewFile(context, uploadedDocument, fullPath);
}

Future<int> uploadDocument(BuildContext context, File file) async {
  final prefs = await SharedPreferences.getInstance();
  var userId = prefs.getInt(USER_ID).toString();

  FormData formData = new FormData.fromMap({
    "apiKey": API_KEY,
    "userId": userId,
    "file": await MultipartFile.fromFile(
      file.path,
      filename: getFileName(file),
    ),
  });
  Response response = await Dio().post(UPLOAD_DOCUMENT_URL, data: formData);
  ResponseWithId statusMsg = responseWithIdFromJson(response.data);
  if (statusMsg.response.status == 203) {
    // Unable to upload due to database or upload error
  } else if (statusMsg.response.status == 202) {
    // File extension not allowed
    showDocumentErrorDialog(
      context,
      DOCUMENT_INVALID_EXTENSION_TITLE,
      DOCUMENT_INVALID_EXTENSION_SUBTITLE +
          ALLOWED_DOCUMENT_EXTENSIONS.toString(),
    );
  } else if (statusMsg.response.status == 201) {
    // File bigger than limit
    showDocumentErrorDialog(
      context,
      DOCUMENT_MAX_SIZE_EXCEEDED_TITLE,
      DOCUMENT_MAX_SIZE_EXCEEDED_SUBTITLE,
    );
  }
  print("File upload response: $response");
  return statusMsg.referenceId;
}

String getFileName(File file) {
  return path.basename(file.path);
}

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
