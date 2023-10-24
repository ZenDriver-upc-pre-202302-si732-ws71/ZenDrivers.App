import 'dart:convert';

import 'package:zendrivers/shared/services/http_service.dart';

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

class DriverExperienceRequest implements JsonSerializable {
  final DateTime startDate;
  final DateTime endDate;
  final String description;

  DriverExperienceRequest({
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory DriverExperienceRequest.fromRawJson(String str) => DriverExperienceRequest.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory DriverExperienceRequest.fromJson(Map<String, dynamic> json) => DriverExperienceRequest(
    startDate: DateTime.parse(json["startDate"]),
    endDate: DateTime.parse(json["endDate"]),
    description: json["description"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "startDate": startDate.toIso8601String(),
    "endDate": endDate.toIso8601String(),
    "description": description,
  };
}