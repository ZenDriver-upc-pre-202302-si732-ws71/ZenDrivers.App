import 'dart:convert';
import 'package:zendrivers/recruiters/entities/comment.dart';
import 'package:zendrivers/recruiters/entities/recruiter.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/shared/utils/converters.dart';

class Post {
  final int id;
  final String title;
  final String description;
  final String image;
  final List<PostLike> likes;
  final List<PostComment> comments;
  final DateTime date;
  final Recruiter recruiter;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.recruiter,
    required this.likes,
    required this.comments
  });

  factory Post.fromRawJson(String str) => Post.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    image: json["image"],
    date: DateTime.parse(json["date"]),
    recruiter: Recruiter.fromJson(json["recruiter"]),
    likes: (json["likes"] as Iterable).jsonIterToList(PostLike.fromJson),
    comments: (json["comments"] as Iterable).jsonIterToList(PostComment.fromJson)
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "image": image,
    "date": date.toIso8601String(),
    "recruiter": recruiter.toJson(),
    "likes": likes.iterToJsonList((l) => l.toJson()),
    "comments": comments.iterToJsonList((c) => c.toJson())
  };


}

class PostSave {
  final String title;
  final String description;
  final String image;

  PostSave({
    required this.title,
    required this.description,
    required this.image,
  });

  factory PostSave.fromRawJson(String str) => PostSave.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostSave.fromJson(Map<String, dynamic> json) => PostSave(
    title: json["title"],
    description: json["description"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "image": image,
  };
}


class PostLike {
  final int id;
  final SimpleAccount account;
  final int postId;

  PostLike({
    required this.id,
    required this.account,
    required this.postId,
  });

  factory PostLike.fromRawJson(String str) => PostLike.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostLike.fromJson(Map<String, dynamic> json) => PostLike(
    id: json["id"],
    account: SimpleAccount.fromJson(json["account"]),
    postId: json["postId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "account": account.toJson(),
    "postId": postId,
  };
}





