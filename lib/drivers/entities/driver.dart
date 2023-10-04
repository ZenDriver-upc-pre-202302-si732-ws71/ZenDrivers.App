import 'dart:convert';
import 'package:zendrivers/drivers/entities/experience.dart';
import 'package:zendrivers/drivers/entities/license.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/shared/utils/converters.dart';

class Driver {
  final List<License> licenses;
  final List<DriverExperience> experiences;
  final int id;
  final String address;
  final DateTime birth;
  final SimpleAccount account;

  Driver({
    required this.licenses,
    required this.experiences,
    required this.id,
    required this.address,
    required this.birth,
    required this.account,
  });

  factory Driver.fromRawJson(String str) => Driver.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    licenses: (json["licenses"] as Iterable).jsonIterToList(License.fromJson),
    experiences: (json["experiences"] as Iterable).jsonIterToList(DriverExperience.fromJson),
    id: json["id"],
    address: json["address"],
    birth: DateTime.parse(json["birth"]),
    account: SimpleAccount.fromJson(json["account"]),
  );

  Map<String, dynamic> toJson() => {
    "licenses": licenses.iterToJsonList((e) => e.toJson()),
    "experiences": experiences.iterToJsonList((e) => e.toJson()),
    "id": id,
    "address": address,
    "birth": birth.toIso8601String(),
    "account": account.toJson(),
  };
}

class DriverResource {
  final int id;
  final String address;
  final DateTime birth;

  DriverResource({
    required this.id,
    required this.address,
    required this.birth,
  });

  factory DriverResource.fromRawJson(String str) => DriverResource.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DriverResource.fromJson(Map<String, dynamic> json) => DriverResource(
    id: json["id"],
    address: json["address"],
    birth: DateTime.parse(json["birth"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "address": address,
    "birth": birth.toIso8601String(),
  };
}

class DriverFindRequest {
  final int yearsOfExperience;
  final String categoryName;

  DriverFindRequest({
    required this.yearsOfExperience,
    required this.categoryName,
  });

  factory DriverFindRequest.fromRawJson(String str) => DriverFindRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DriverFindRequest.fromJson(Map<String, dynamic> json) => DriverFindRequest(
    yearsOfExperience: json["yearsOfExperience"],
    categoryName: json["categoryName"],
  );

  Map<String, dynamic> toJson() => {
    "yearsOfExperience": yearsOfExperience,
    "categoryName": categoryName,
  };
}


