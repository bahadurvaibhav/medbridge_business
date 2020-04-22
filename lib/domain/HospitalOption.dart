import 'dart:convert';

import 'package:medbridge_business/gateway/HospitalOptionResponse.dart';

String hospitalOptionsToJson(List<HospitalOption> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

List<HospitalOption> toHospitalOption(List<HospitalOptionResponse> data) {
  List<HospitalOption> options = new List();
  data.forEach((response) {
    options.add(new HospitalOption(
      response.hospitalId,
      response.hospitalName,
      response.treatmentName,
      response.hospitalStayDuration,
      response.completeStayDuration,
      response.cost,
      response.travelAssistNotes,
      response.accommodationAssistNotes,
      response.notes,
    ));
  });
  return options;
}

class HospitalOption {
  String hospitalId;
  String hospitalName;
  String treatmentName;
  String hospitalStayDuration;
  String completeStayDuration;
  String cost;
  String travelAssistNotes;
  String accommodationAssistNotes;
  String notes;

  HospitalOption(
    this.hospitalId,
    this.hospitalName,
    this.treatmentName,
    this.hospitalStayDuration,
    this.completeStayDuration,
    this.cost,
    this.travelAssistNotes,
    this.accommodationAssistNotes,
    this.notes,
  );

  Map<String, dynamic> toJson() => {
        "hospitalId": hospitalId,
        "hospitalName": hospitalName,
        "treatmentName": treatmentName,
        "hospitalStayDuration": hospitalStayDuration,
        "completeStayDuration": completeStayDuration,
        "cost": cost,
        "travelAssistNotes": travelAssistNotes,
        "accommodationAssistNotes": accommodationAssistNotes,
        "notes": notes,
      };
}
