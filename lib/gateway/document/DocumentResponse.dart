class PatientDocument {
  String id;
  DateTime created;
  String documentDescription;
  String documentName;
  String storedDocumentName;

  PatientDocument({
    this.id,
    this.created,
    this.documentDescription,
    this.documentName,
    this.storedDocumentName,
  });

  factory PatientDocument.fromJson(Map<String, dynamic> json) =>
      PatientDocument(
        id: json["id"],
        created: DateTime.parse(json["created"]),
        documentDescription: json["documentDescription"],
        documentName: json["documentName"],
        storedDocumentName: json["storedDocumentName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created": created.toIso8601String(),
        "documentDescription": documentDescription,
        "documentName": documentName,
        "storedDocumentName": storedDocumentName,
      };
}
