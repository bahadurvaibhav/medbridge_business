enum Status {
  NEW_PATIENT,
  PATIENT_SUBMITTED,
  HOSPITAL_OPTIONS,
  TREATMENT_CONFIRMED,
  TREATMENT_ONGOING,
  TREATMENT_COMPLETED,
}

final statusValues = EnumValues({
  "NEW_PATIENT": Status.NEW_PATIENT,
  "PATIENT_SUBMITTED": Status.PATIENT_SUBMITTED,
  "HOSPITAL_OPTIONS": Status.HOSPITAL_OPTIONS,
  "TREATMENT_CONFIRMED": Status.TREATMENT_CONFIRMED,
  "TREATMENT_ONGOING": Status.TREATMENT_ONGOING,
  "TREATMENT_COMPLETED": Status.TREATMENT_COMPLETED,
});

final statusReadable = EnumValues({
  "New Patient": Status.NEW_PATIENT,
  "Patient Submitted": Status.PATIENT_SUBMITTED,
  "Hospital Options": Status.HOSPITAL_OPTIONS,
  "Treatment Confirmed": Status.TREATMENT_CONFIRMED,
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
