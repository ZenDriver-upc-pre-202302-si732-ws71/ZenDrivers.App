import 'dart:convert';
import 'package:zendrivers/drivers/entities/driver.dart';
import 'package:zendrivers/recruiters/entities/recruiter.dart';
import 'package:zendrivers/security/entities/login.dart';

class Account {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String phone;
  final UserType role;
  final String imageUrl;
  final RecruiterResource? recruiter;
  final DriverResource? driver;

  Account({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.phone,
    required this.role,
    required this.imageUrl,
    this.recruiter,
    this.driver,
  });

  factory Account.fromRawJson(String str) => Account.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json["id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    username: json["username"],
    phone: json["phone"],
    role: roleFromString(json["role"]),
    imageUrl: json["imageUrl"],
    recruiter: json["recruiter"] != null ? RecruiterResource.fromJson(json["recruiter"]) : null,
    driver: json["driver"] != null ? DriverResource.fromJson(json["driver"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "phone": phone,
    "imageUrl": imageUrl,
    "role": roleToString(role),
    "recruiter": recruiter?.toJson(),
    "driver": driver?.toJson(),
  };
}

class SimpleAccount {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String phone;
  final UserType role;
  final String? imageUrl;

  bool get isDriver => role == UserType.driver;
  bool get isRecruiter => role == UserType.recruiter;

  SimpleAccount({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.phone,
    required this.role,
    this.imageUrl,
  });

  factory SimpleAccount.fromRawJson(String str) => SimpleAccount.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SimpleAccount.fromJson(Map<String, dynamic> json) => SimpleAccount(
    id: json["id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    username: json["username"],
    phone: json["phone"],
    role: roleFromString(json["role"]),
    imageUrl: json["imageUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "phone": phone,
    "role": roleToString(role),
    "imageUrl": imageUrl,
  };
}


class AccountUpdateRequest {
  final String? firstname;
  final String? lastname;
  final String? username;
  final String? password;
  final String? phone;
  final RecruiterUpdate? recruiter;
  final DriverUpdate? driver;

  AccountUpdateRequest({
    this.firstname,
    this.lastname,
    this.username,
    this.password,
    this.phone,
    this.recruiter,
    this.driver,
  });

  factory AccountUpdateRequest.fromRawJson(String str) => AccountUpdateRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AccountUpdateRequest.fromJson(Map<String, dynamic> json) => AccountUpdateRequest(
    firstname: json["firstname"],
    lastname: json["lastname"],
    username: json["username"],
    password: json["password"],
    phone: json["phone"],
    recruiter: json["recruiter"] == null ? null : RecruiterUpdate.fromJson(json["recruiter"]),
    driver: json["driver"] == null ? null : DriverUpdate.fromJson(json["driver"]),
  );

  Map<String, dynamic> toJson() => {
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "password": password,
    "phone": phone,
    "recruiter": recruiter?.toJson(),
    "driver": driver?.toJson(),
  };
}

class DriverUpdate {
  final String? address;
  final DateTime? birth;

  DriverUpdate({
    this.address,
    this.birth,
  });

  factory DriverUpdate.fromRawJson(String str) => DriverUpdate.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DriverUpdate.fromJson(Map<String, dynamic> json) => DriverUpdate(
    address: json["address"],
    birth: json["birth"] == null ? null : DateTime.parse(json["birth"]),
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "birth": birth?.toIso8601String(),
  };
}

class RecruiterUpdate {
  final String? email;
  final String? description;

  RecruiterUpdate({
    this.email,
    this.description,
  });

  factory RecruiterUpdate.fromRawJson(String str) => RecruiterUpdate.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecruiterUpdate.fromJson(Map<String, dynamic> json) => RecruiterUpdate(
    email: json["email"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "description": description,
  };
}


class AuthenticateRequest {
  final String username;
  final String token;

  AuthenticateRequest({
    required this.username,
    required this.token,
  });

  factory AuthenticateRequest.fromRawJson(String str) => AuthenticateRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthenticateRequest.fromJson(Map<String, dynamic> json) => AuthenticateRequest(
    username: json["username"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "token": token,
  };
}
