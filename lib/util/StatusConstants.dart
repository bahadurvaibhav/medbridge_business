enum Status {
  NEW_PATIENT,
  PATIENT_SUBMITTED,
  HOSPITAL_OPTIONS,
}

final statusValues = EnumValues({
  "NEW_PATIENT": Status.NEW_PATIENT,
  "PATIENT_SUBMITTED": Status.PATIENT_SUBMITTED,
  "HOSPITAL_OPTIONS": Status.HOSPITAL_OPTIONS,
});

final statusReadable = EnumValues({
  "New Patient": Status.NEW_PATIENT,
  "Patient Submitted": Status.PATIENT_SUBMITTED,
  "Hospital Options": Status.HOSPITAL_OPTIONS,
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
