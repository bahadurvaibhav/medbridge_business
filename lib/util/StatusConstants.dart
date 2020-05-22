enum Status {
  NEW_PATIENT,
  PATIENT_SUBMITTED,
  HOSPITAL_OPTIONS,
  TREATMENT_CONFIRMED,
  TRAVEL_STATUS_UPDATE,
  VISA_APPOINTMENT,
  TRAVEL_STATUS_CONFIRMED,
  PATIENT_RECEIVED,
  TREATMENT_ONGOING,
  TREATMENT_COMPLETED,
}

final statusValues = EnumValues({
  "NEW_PATIENT": Status.NEW_PATIENT,
  "PATIENT_SUBMITTED": Status.PATIENT_SUBMITTED,
  "HOSPITAL_OPTIONS": Status.HOSPITAL_OPTIONS,
  "TREATMENT_CONFIRMED": Status.TREATMENT_CONFIRMED,
  "TRAVEL_STATUS_UPDATE": Status.TRAVEL_STATUS_UPDATE,
  "VISA_APPOINTMENT": Status.VISA_APPOINTMENT,
  "TRAVEL_STATUS_CONFIRMED": Status.TRAVEL_STATUS_CONFIRMED,
  "PATIENT_RECEIVED": Status.PATIENT_RECEIVED,
  "TREATMENT_ONGOING": Status.TREATMENT_ONGOING,
  "TREATMENT_COMPLETED": Status.TREATMENT_COMPLETED,
});

final statusReadable = EnumValues({
  "New Patient": Status.NEW_PATIENT,
  "Patient Submitted": Status.PATIENT_SUBMITTED,
  "Treatment Plan Provided": Status.HOSPITAL_OPTIONS,
  "Treatment Plan Accepted": Status.TREATMENT_CONFIRMED,
  "Travel Status Update": Status.TRAVEL_STATUS_UPDATE,
  "Visa Appointment": Status.VISA_APPOINTMENT,
  "Travel Status Confirmed": Status.TRAVEL_STATUS_CONFIRMED,
  "Patient Received": Status.PATIENT_RECEIVED,
  "Treatment Ongoing": Status.TREATMENT_ONGOING,
  "Treatment Completed": Status.TREATMENT_COMPLETED,
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
