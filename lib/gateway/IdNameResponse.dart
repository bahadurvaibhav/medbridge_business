class IdNameResponse {
  String id;
  String name;

  IdNameResponse({
    this.id,
    this.name,
  });

  factory IdNameResponse.fromJson(Map<String, dynamic> json) => IdNameResponse(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
