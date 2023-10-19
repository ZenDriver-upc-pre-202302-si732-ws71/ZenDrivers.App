import 'dart:convert';
import 'package:zendrivers/recruiters/entities/company.dart';
import 'package:zendrivers/security/entities/account.dart';

class Recruiter {
  final int id;
  final String email;
  final String description;
  final Company company;
  final SimpleAccount account;

  Recruiter({
    required this.id,
    required this.email,
    required this.description,
    required this.company,
    required this.account,
  });

  factory Recruiter.fromRawJson(String str) => Recruiter.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Recruiter.fromJson(Map<String, dynamic> json) => Recruiter(
    id: json["id"],
    email: json["email"],
    description: json["description"],
    company: Company.fromJson(json["company"]),
    account: SimpleAccount.fromJson(json["account"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "description": description,
    "company": company.toJson(),
    "account": account.toJson(),
  };
}

class RecruiterResource {
  final int id;
  final String email;
  final String description;
  final Company company;

  RecruiterResource({
    required this.id,
    required this.email,
    required this.description,
    required this.company,
  });

  factory RecruiterResource.fromRawJson(String str) => RecruiterResource.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecruiterResource.fromJson(Map<String, dynamic> json) => RecruiterResource(
    id: json["id"],
    email: json["email"],
    description: json["description"],
    company: Company.fromJson(json["company"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "description": description,
    "company": company.toJson(),
  };

  RecruiterResource fromUpdate(RecruiterUpdate request) => RecruiterResource(
    id: id,
    company: company,
    email: request.email ?? email,
    description: request.description ?? description
  );
}