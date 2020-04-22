class Document {
  String id;
  DateTime created;
  String documentDescription;
  String documentName;
  String storedDocumentName;

  Document({
    this.id,
    this.created,
    this.documentDescription,
    this.documentName,
    this.storedDocumentName,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
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
