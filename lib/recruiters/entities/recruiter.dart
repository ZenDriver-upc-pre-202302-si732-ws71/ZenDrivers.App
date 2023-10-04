import 'dart:convert';
import 'package:zendrivers/security/entities/account.dart';

class Recruiter {
  final int id;
  final String email;
  final String description;
  final int companyId;
  final SimpleAccount account;

  Recruiter({
    required this.id,
    required this.email,
    required this.description,
    required this.companyId,
    required this.account,
  });

  factory Recruiter.fromRawJson(String str) => Recruiter.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Recruiter.fromJson(Map<String, dynamic> json) => Recruiter(
    id: json["id"],
    email: json["email"],
    description: json["description"],
    companyId: json["companyId"],
    account: SimpleAccount.fromJson(json["account"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "description": description,
    "companyId": companyId,
    "account": account.toJson(),
  };
}

class RecruiterResource {
  final int id;
  final String email;
  final String description;
  final int companyId;

  RecruiterResource({
    required this.id,
    required this.email,
    required this.description,
    required this.companyId,
  });

  factory RecruiterResource.fromRawJson(String str) => RecruiterResource.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecruiterResource.fromJson(Map<String, dynamic> json) => RecruiterResource(
    id: json["id"],
    email: json["email"],
    description: json["description"],
    companyId: json["companyId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "description": description,
    "companyId": companyId,
  };
}