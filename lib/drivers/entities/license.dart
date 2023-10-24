import 'dart:convert';

import 'package:zendrivers/shared/services/http_service.dart';

class License {
  final int id;
  final DateTime start;
  final DateTime end;
  final LicenseCategory category;

  License({
    required this.id,
    required this.start,
    required this.end,
    required this.category,
  });

  factory License.fromRawJson(String str) => License.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory License.fromJson(Map<String, dynamic> json) => License(
    id: json["id"],
    start: DateTime.parse(json["start"]),
    end: DateTime.parse(json["end"]),
    category: LicenseCategory.fromJson(json["category"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "start": start.toIso8601String(),
    "end": end.toIso8601String(),
    "category": category.toJson(),
  };
}

class LicenseCategory {
  final int id;
  final String name;

  LicenseCategory({
    required this.id,
    required this.name,
  });

  factory LicenseCategory.fromRawJson(String str) => LicenseCategory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LicenseCategory.fromJson(Map<String, dynamic> json) => LicenseCategory(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}


class LicenseRequest implements JsonSerializable {
  final int categoryId;
  final DateTime start;
  final DateTime end;

  LicenseRequest({
    required this.categoryId,
    required this.start,
    required this.end,
  });

  factory LicenseRequest.fromRawJson(String str) => LicenseRequest.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory LicenseRequest.fromJson(Map<String, dynamic> json) => LicenseRequest(
    categoryId: json["categoryId"],
    start: DateTime.parse(json["start"]),
    end: DateTime.parse(json["end"]),
  );

  @override
  Map<String, dynamic> toJson() => {
    "categoryId": categoryId,
    "start": start.toIso8601String(),
    "end": end.toIso8601String(),
  };
}
