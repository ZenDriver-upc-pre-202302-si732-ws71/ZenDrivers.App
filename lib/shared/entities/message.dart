import 'dart:convert';

import 'package:zendrivers/security/entities/account.dart';

class Message {
  final int id;
  final String content;
  final DateTime date;
  final Account receiver;
  final Account sender;

  Message({
    required this.id,
    required this.content,
    required this.date,
    required this.receiver,
    required this.sender,
  });

  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    content: json["content"],
    date: DateTime.parse(json["date"]),
    receiver: Account.fromJson(json["receiver"]),
    sender: Account.fromJson(json["sender"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "date": date.toIso8601String(),
    "receiver": receiver.toJson(),
    "sender": sender.toJson(),
  };
}

class MessageRequest {
  final String content;
  final String receiverUsername;

  MessageRequest({
    required this.content,
    required this.receiverUsername,
  });

  factory MessageRequest.fromRawJson(String str) => MessageRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MessageRequest.fromJson(Map<String, dynamic> json) => MessageRequest(
    content: json["content"],
    receiverUsername: json["receiverUsername"],
  );

  Map<String, dynamic> toJson() => {
    "content": content,
    "receiverUsername": receiverUsername,
  };
}

class ConversationRequest {
  final String receiverUsername;
  final String senderUsername;

  ConversationRequest({
    required this.receiverUsername,
    required this.senderUsername,
  });

  factory ConversationRequest.fromRawJson(String str) => ConversationRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ConversationRequest.fromJson(Map<String, dynamic> json) => ConversationRequest(
    receiverUsername: json["receiverUsername"],
    senderUsername: json["senderUsername"],
  );

  Map<String, dynamic> toJson() => {
    "receiverUsername": receiverUsername,
    "senderUsername": senderUsername,
  };
}