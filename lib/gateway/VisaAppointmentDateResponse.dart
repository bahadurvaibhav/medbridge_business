import 'dart:convert';

import 'package:medbridge_business/gateway/StatusMsg.dart';
import 'package:medbridge_business/gateway/TravelStatusResponse.dart';

VisaAppointmentDateResponse visaAppointmentDateResponseFromJson(String str) =>
    VisaAppointmentDateResponse.fromJson(json.decode(str));

String visaAppointmentDateResponseToJson(VisaAppointmentDateResponse data) =>
    json.encode(data.toJson());

class VisaAppointmentDateResponse {
  VisaAppointmentDateResponse({
    this.response,
    this.visaAppointmentDate,
    this.visaInvitationLetters,
    this.visaAppointmentFiles,
  });

  StatusMsg response;
  DateTime visaAppointmentDate;
  List<Document> visaInvitationLetters;
  List<Document> visaAppointmentFiles;

  factory VisaAppointmentDateResponse.fromJson(Map<String, dynamic> json) =>
      VisaAppointmentDateResponse(
        response: StatusMsg.fromJson(json["response"]),
        visaAppointmentDate: DateTime.parse(json["visaAppointmentDate"]),
        visaInvitationLetters: List<Document>.from(
            json["visaInvitationLetters"].map((x) => Document.fromJson(x))),
        visaAppointmentFiles: List<Document>.from(
            json["visaAppointmentFiles"].map((x) => Document.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "visaAppointmentDate": visaAppointmentDate.toIso8601String(),
        "visaInvitationLetters":
            List<dynamic>.from(visaInvitationLetters.map((x) => x.toJson())),
        "visaAppointmentFiles":
            List<dynamic>.from(visaAppointmentFiles.map((x) => x.toJson())),
      };
}
