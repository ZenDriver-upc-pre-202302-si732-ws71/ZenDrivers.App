import 'dart:convert';

class MessageResponse {
  final String message;
  bool valid = false;

  MessageResponse({
    required this.message,
  });

  factory MessageResponse.empty() => MessageResponse(message: "");

  bool get isEmpty => message.isEmpty;

  factory MessageResponse.fromRawJson(String str) => MessageResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MessageResponse.fromJson(Map<String, dynamic> json) => MessageResponse(
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
  };
}