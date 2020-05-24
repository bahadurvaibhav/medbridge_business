import 'dart:convert';

import 'package:medbridge_business/gateway/StatusMsg.dart';

TravelStatusResponse travelStatusResponseFromJson(String str) =>
    TravelStatusResponse.fromJson(json.decode(str));

String travelStatusResponseToJson(TravelStatusResponse data) =>
    json.encode(data.toJson());

class TravelStatusResponse {
  StatusMsg response;
  TravelStatus travelStatus;

  TravelStatusResponse({
    this.response,
    this.travelStatus,
  });

  factory TravelStatusResponse.fromJson(Map<String, dynamic> json) =>
      TravelStatusResponse(
        response: StatusMsg.fromJson(json["response"]),
        travelStatus: TravelStatus.fromJson(json["travelStatus"]),
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "travelStatus": travelStatus.toJson(),
      };
}

class TravelStatus {
  String id;
  String patientId;
  String budgetForAcco;
  String arrivalDate;
  String visaAppointmentDate;
  String uploadedPassport;
  String uploadedVisaAppointmentForm;
  DateTime created;
  List<Document> passportDocuments;
  List<Document> visaAppointmentDocuments;

  TravelStatus({
    this.id,
    this.patientId,
    this.budgetForAcco,
    this.arrivalDate,
    this.visaAppointmentDate,
    this.uploadedPassport,
    this.uploadedVisaAppointmentForm,
    this.created,
    this.passportDocuments,
    this.visaAppointmentDocuments,
  });

  factory TravelStatus.fromJson(Map<String, dynamic> json) => TravelStatus(
        id: json["id"],
        patientId: json["patientId"],
        budgetForAcco: json["budgetForAcco"],
        arrivalDate: json["arrivalDate"],
        visaAppointmentDate: json["visaAppointmentDate"],
        uploadedPassport: json["uploadedPassport"],
        uploadedVisaAppointmentForm: json["uploadedVisaAppointmentForm"],
        created: DateTime.parse(json["created"]),
        passportDocuments: List<Document>.from(
            json["passportDocuments"].map((x) => Document.fromJson(x))),
        visaAppointmentDocuments: List<Document>.from(
            json["visaAppointmentDocuments"].map((x) => Document.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patientId": patientId,
        "budgetForAcco": budgetForAcco,
        "arrivalDate": arrivalDate,
        "visaAppointmentDate": visaAppointmentDate,
        "uploadedPassport": uploadedPassport,
        "uploadedVisaAppointmentForm": uploadedVisaAppointmentForm,
        "created": created.toIso8601String(),
        "passportDocuments":
            List<dynamic>.from(passportDocuments.map((x) => x.toJson())),
        "visaAppointmentDocuments":
            List<dynamic>.from(visaAppointmentDocuments.map((x) => x.toJson())),
      };
}

class Document {
  String id;
  String documentName;
  String documentSize;
  String userId;
  DateTime created;
  String storedDocumentName;

  Document({
    this.id,
    this.documentName,
    this.documentSize,
    this.userId,
    this.created,
    this.storedDocumentName,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        id: json["id"],
        documentName: json["documentName"],
        documentSize: json["documentSize"],
        userId: json["userId"],
        created: DateTime.parse(json["created"]),
        storedDocumentName: json["storedDocumentName"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "documentName": documentName,
        "documentSize": documentSize,
        "userId": userId,
        "created": created.toIso8601String(),
        "storedDocumentName": storedDocumentName,
      };
}
