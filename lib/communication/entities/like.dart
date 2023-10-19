import 'dart:convert';

import 'package:zendrivers/shared/services/http_service.dart';

class LikeRequest extends JsonSerializable {
  final int postId;

  LikeRequest({
    required this.postId,
  });

  factory LikeRequest.fromRawJson(String str) => LikeRequest.fromJson(json.decode(str));

  @override
  String toRawJson() => json.encode(toJson());

  factory LikeRequest.fromJson(Map<String, dynamic> json) => LikeRequest(
    postId: json["postId"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "postId": postId,
  };
}
