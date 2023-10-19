import 'dart:convert';

class Company {
  final int id;
  final String name;
  final String ruc;
  final String owner;
  final String address;

  Company({
    required this.id,
    required this.name,
    required this.ruc,
    required this.owner,
    required this.address,
  });

  factory Company.fromRawJson(String str) => Company.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json["id"],
    name: json["name"],
    ruc: json["ruc"],
    owner: json["owner"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "ruc": ruc,
    "owner": owner,
    "address": address,
  };

  @override
  bool operator ==(Object other) => other.toString() == id.toString();

  @override
  String toString() => id.toString();

  @override
  int get hashCode => toString().hashCode;
}
