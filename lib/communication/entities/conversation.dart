import 'dart:convert';
import 'package:zendrivers/communication/entities/message.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';

class Conversation extends JsonSerializable {
  final int id;
  final SimpleAccount sender;
  final SimpleAccount receiver;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.messages,
  });

  factory Conversation.fromRawJson(String str) => Conversation.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
    id: json["id"],
    sender: SimpleAccount.fromJson(json["sender"]),
    receiver: SimpleAccount.fromJson(json["receiver"]),
    messages: (json["messages"] as Iterable).jsonIterToList(Message.fromJson),
  );

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "sender": sender.toJson(),
    "receiver": receiver.toJson(),
    "messages": messages.iterToJsonList((m) => m.toJson()),
  };
}


class ConversationRequest {
  final String firstUsername;
  final String secondUsername;

  ConversationRequest({
    required this.firstUsername,
    required this.secondUsername,
  });

  factory ConversationRequest.fromRawJson(String str) => ConversationRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ConversationRequest.fromJson(Map<String, dynamic> json) => ConversationRequest(
    firstUsername: json["firstUsername"],
    secondUsername: json["secondUsername"],
  );

  Map<String, dynamic> toJson() => {
    "firstUsername": firstUsername,
    "secondUsername": secondUsername,
  };
}

