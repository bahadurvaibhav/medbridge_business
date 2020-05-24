import 'dart:convert';

import 'package:medbridge_business/gateway/StatusMsg.dart';

VisaAppointmentDateResponse visaAppointmentDateResponseFromJson(String str) =>
    VisaAppointmentDateResponse.fromJson(json.decode(str));

String visaAppointmentDateResponseToJson(VisaAppointmentDateResponse data) =>
    json.encode(data.toJson());

class VisaAppointmentDateResponse {
  StatusMsg response;
  DateTime visaAppointmentDate;

  VisaAppointmentDateResponse({
    this.response,
    this.visaAppointmentDate,
  });

  factory VisaAppointmentDateResponse.fromJson(Map<String, dynamic> json) =>
      VisaAppointmentDateResponse(
        response: StatusMsg.fromJson(json["response"]),
        visaAppointmentDate: DateTime.parse(json["visaAppointmentDate"]),
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "visaAppointmentDate": visaAppointmentDate.toIso8601String(),
      };
}
