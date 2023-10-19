import 'dart:convert';

import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/shared/services/http_service.dart';

class PostComment {
  final int id;
  final String content;
  final SimpleAccount account;
  final DateTime date;
  final int postId;

  PostComment({
    required this.id,
    required this.content,
    required this.account,
    required this.date,
    required this.postId,
  });

  factory PostComment.fromRawJson(String str) => PostComment.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostComment.fromJson(Map<String, dynamic> json) => PostComment(
    id: json["id"],
    content: json["content"],
    account: SimpleAccount.fromJson(json["account"]),
    date: DateTime.parse(json["date"]),
    postId: json["postId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "account": account.toJson(),
    "date": date.toIso8601String(),
    "postId": postId,
  };

}

class PostCommentRequest extends JsonSerializable {
  final String content;
  final int postId;

  PostCommentRequest({
    required this.content,
    required this.postId,
  });

  factory PostCommentRequest.fromRawJson(String str) => PostCommentRequest.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory PostCommentRequest.fromJson(Map<String, dynamic> json) => PostCommentRequest(
    content: json["content"],
    postId: json["postId"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "content": content,
    "postId": postId
  };
}
