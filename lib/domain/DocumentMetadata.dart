import 'dart:convert';

String documentMetadataToJson(List<DocumentMetadata> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DocumentMetadata {
  int documentId;
  String description;
  String fileName;
  String storedDocumentName;

  DocumentMetadata(
    this.documentId,
    this.description,
    this.fileName,
    this.storedDocumentName,
  );

  Map<String, dynamic> toJson() => {
        "documentId": documentId,
        "description": description,
      };
}
