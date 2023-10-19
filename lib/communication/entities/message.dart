import 'dart:convert';

import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/shared/services/http_service.dart';


class Message {
  final int id;
  final String content;
  final DateTime date;
  final SimpleAccount account;

  Message({
    required this.id,
    required this.content,
    required this.date,
    required this.account
  });

  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    content: json["content"],
    date: DateTime.parse(json["date"]),
    account: SimpleAccount.fromJson(json["account"])
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "date": date.toIso8601String(),
    "account": account.toJson()
  };
}


class MessageRequest extends JsonSerializable {
  final String content;
  final String receiverUsername;

  MessageRequest({
    required this.content,
    required this.receiverUsername,
  });

  factory MessageRequest.fromRawJson(String str) => MessageRequest.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory MessageRequest.fromJson(Map<String, dynamic> json) => MessageRequest(
    content: json["content"],
    receiverUsername: json["receiverUsername"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "content": content,
    "receiverUsername": receiverUsername,
  };
}
