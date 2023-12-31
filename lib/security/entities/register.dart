import 'dart:convert';

import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/services/http_service.dart';

class SignupRequest extends JsonSerializable {
  final String firstname;
  final String lastname;
  final String username;
  final String password;
  final String phone;
  final String? imageUrl;
  final UserType role;
  final RecruiterSave? recruiter;
  final DriverSave? driver;

  SignupRequest({
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.password,
    required this.phone,
    required this.role,
    this.imageUrl,
    this.recruiter,
    this.driver,
  });

  factory SignupRequest.fromRawJson(String str) => SignupRequest.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory SignupRequest.fromJson(Map<String, dynamic> json) => SignupRequest(
    firstname: json["firstname"],
    lastname: json["lastname"],
    username: json["username"],
    password: json["password"],
    phone: json["phone"],
    role: roleFromString(json["role"]),
    recruiter: json["recruiter"] != null ? RecruiterSave.fromJson(json["recruiter"]) : null,
    driver: json["driver"] != null ? DriverSave.fromJson(json["driver"]) : null,
    imageUrl: json["imageUrl"]
  );

  @override
  Map<String, dynamic> toJson() => {
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "password": password,
    "phone": phone,
    "role": roleToString(role),
    "recruiter": recruiter?.toJson(),
    "driver": driver?.toJson(),
    "imageUrl": imageUrl
  };
}

class DriverSave {
  final String address;
  final DateTime birth;

  DriverSave({
    required this.address,
    required this.birth,
  });

  factory DriverSave.fromRawJson(String str) => DriverSave.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DriverSave.fromJson(Map<String, dynamic> json) => DriverSave(
    address: json["address"],
    birth: DateTime.parse(json["birth"]),
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "birth": birth.toIso8601String(),
  };
}

class RecruiterSave {
  final String email;
  final String description;
  final int companyId;

  RecruiterSave({
    required this.email,
    required this.description,
    required this.companyId,
  });

  factory RecruiterSave.fromRawJson(String str) => RecruiterSave.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecruiterSave.fromJson(Map<String, dynamic> json) => RecruiterSave(
    email: json["email"],
    description: json["description"],
    companyId: int.parse(json["companyId"].toString()),
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "description": description,
    "companyId": companyId,
  };
}



