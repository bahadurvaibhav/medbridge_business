class HospitalOptionResponse {
  String id;
  String patientId;
  String addedBy;
  String hospitalId;
  String hospitalName;
  String cost;
  DateTime created;
  String treatmentName;
  String hospitalStayDuration;
  String completeStayDuration;
  String travelAssistNotes;
  String accommodationAssistNotes;
  String notes;

  HospitalOptionResponse({
    this.id,
    this.patientId,
    this.addedBy,
    this.hospitalId,
    this.hospitalName,
    this.cost,
    this.created,
    this.treatmentName,
    this.hospitalStayDuration,
    this.completeStayDuration,
    this.travelAssistNotes,
    this.accommodationAssistNotes,
    this.notes,
  });

  factory HospitalOptionResponse.fromJson(Map<String, dynamic> json) =>
      HospitalOptionResponse(
        id: json["id"],
        patientId: json["patientId"],
        addedBy: json["addedBy"],
        hospitalId: json["hospitalId"],
        hospitalName: json["hospitalName"],
        cost: json["cost"],
        created: DateTime.parse(json["created"]),
        treatmentName: json["treatmentName"],
        hospitalStayDuration: json["hospitalStayDuration"],
        completeStayDuration: json["completeStayDuration"],
        travelAssistNotes: json["travelAssistNotes"],
        accommodationAssistNotes: json["accommodationAssistNotes"],
        notes: json["notes"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patientId": patientId,
        "addedBy": addedBy,
        "hospitalId": hospitalId,
        "hospitalName": hospitalName,
        "cost": cost,
        "created": created.toIso8601String(),
        "treatmentName": treatmentName,
        "hospitalStayDuration": hospitalStayDuration,
        "completeStayDuration": completeStayDuration,
        "travelAssistNotes": travelAssistNotes,
        "accommodationAssistNotes": accommodationAssistNotes,
        "notes": notes,
      };
}
