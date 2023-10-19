import 'dart:convert';

import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/shared/services/http_service.dart';

class LoginRequest extends JsonSerializable {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  factory LoginRequest.fromRawJson(String str) => LoginRequest.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    username: json["username"],
    password: json["password"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
  };
}

class LoginResponse {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String? imageUrl;
  final String token;
  final UserType role;

  bool get isDriver => role == UserType.driver;
  bool get isRecruiter => role == UserType.recruiter;

  LoginResponse({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    this.imageUrl,
    required this.token,
    required this.role
  });

  factory LoginResponse.fromRawJson(String str) => LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    id: json["id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    username: json["username"],
    imageUrl: json["imageUrl"],
    token: json["token"],
    role: roleFromString(json["role"])
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "imageUrl": imageUrl,
    "token": token,
    "role": roleToString(role)
  };

  SimpleAccount toSimpleAccount() => SimpleAccount(
    id: 0,
    firstname: firstname,
    lastname: lastname,
    username: username,
    imageUrl: imageUrl,
    role: role,
    phone: ""
  );
}

enum UserType {
  driver,
  recruiter,
  none
}

UserType roleFromString(String? role) {
  if(role == null) {
    return UserType.none;
  }
  role = role.toLowerCase();
  if(role == "driver") {
    return UserType.driver;
  }
  else if(role == "recruiter") {
    return UserType.recruiter;
  }

  return UserType.none;
}

String roleToString(UserType role) {
  if(role == UserType.driver){
    return "driver";
  }
  else if(role == UserType.recruiter) {
    return "recruiter";
  }
  return "none";
}
