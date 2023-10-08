import 'dart:convert';

class LikeRequest {
  final int postId;

  LikeRequest({
    required this.postId,
  });

  factory LikeRequest.fromRawJson(String str) => LikeRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LikeRequest.fromJson(Map<String, dynamic> json) => LikeRequest(
    postId: json["postId"],
  );

  Map<String, dynamic> toJson() => {
    "postId": postId,
  };
}
