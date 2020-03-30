import 'dart:convert';

String documentMetadataToJson(List<DocumentMetadata> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DocumentMetadata {
  int documentId;
  String description;
  String fileName;

  DocumentMetadata(this.documentId, this.description, this.fileName);

  Map<String, dynamic> toJson() => {
        "documentId": documentId,
        "description": description,
      };
}
