import 'dart:convert';

class DriverExperience {
  final int id;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  DriverExperience({
    required this.id,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  factory DriverExperience.fromRawJson(String str) => DriverExperience.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DriverExperience.fromJson(Map<String, dynamic> json) => DriverExperience(
    id: json["id"],
    description: json["description"],
    startDate: DateTime.parse(json["startDate"]),
    endDate: DateTime.parse(json["endDate"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "description": description,
    "startDate": startDate.toIso8601String(),
    "endDate": endDate.toIso8601String(),
  };
}