import 'dart:convert';

import 'package:medbridge_business/gateway/HospitalOptionResponse.dart';
import 'package:medbridge_business/gateway/document/DocumentResponse.dart';
import 'package:medbridge_business/util/StatusConstants.dart';

List<PatientResponse> patientResponseFromJson(String str) =>
    List<PatientResponse>.from(
        json.decode(str).map((x) => PatientResponse.fromJson(x)));

String patientResponseToJson(List<PatientResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PatientResponse {
  String id;
  String userId;
  Status status;
  String patientName;
  String patientPhone;
  String patientEmail;
  String patientCountry;
  String patientProblem;
  String patientPreferredDestination;
  String patientTravelAssist;
  String patientAccommodationAssist;
  String preferredHospitalId;
  DateTime created;
  List<PatientDocument> documents;
  List<HospitalOptionResponse> hospitalOptions;
  String finalCost;

  PatientResponse({
    this.id,
    this.userId,
    this.status,
    this.patientName,
    this.patientPhone,
    this.patientEmail,
    this.patientCountry,
    this.patientProblem,
    this.patientPreferredDestination,
    this.patientTravelAssist,
    this.patientAccommodationAssist,
    this.preferredHospitalId,
    this.created,
    this.documents,
    this.hospitalOptions,
    this.finalCost,
  });

  factory PatientResponse.fromJson(Map<String, dynamic> json) =>
      PatientResponse(
        id: json["id"],
        userId: json["userId"],
        status: statusValues.map[json["status"]],
        patientName: json["patientName"],
        patientPhone: json["patientPhone"],
        patientEmail: json["patientEmail"],
        patientCountry: json["patientCountry"],
        patientProblem: json["patientProblem"],
        patientPreferredDestination: json["patientPreferredDestination"],
        patientTravelAssist: json["patientTravelAssist"],
        patientAccommodationAssist: json["patientAccommodationAssist"],
        preferredHospitalId: json["preferredHospitalId"],
        created: DateTime.parse(json["created"]),
        documents: List<PatientDocument>.from(
            json["documents"].map((x) => PatientDocument.fromJson(x))),
        hospitalOptions: List<HospitalOptionResponse>.from(
            json["hospitalOptions"]
                .map((x) => HospitalOptionResponse.fromJson(x))),
        finalCost: json["finalCost"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "status": statusValues.reverse[status],
        "patientName": patientName,
        "patientPhone": patientPhone,
        "patientEmail": patientEmail,
        "patientCountry": patientCountry,
        "patientProblem": patientProblem,
        "patientPreferredDestination": patientPreferredDestination,
        "patientTravelAssist": patientTravelAssist,
        "patientAccommodationAssist": patientAccommodationAssist,
        "preferredHospitalId": preferredHospitalId,
        "created": created.toIso8601String(),
        "documents": List<dynamic>.from(documents.map((x) => x.toJson())),
        "hospitalOptions":
            List<dynamic>.from(hospitalOptions.map((x) => x.toJson())),
        "finalCost": finalCost,
      };
}
