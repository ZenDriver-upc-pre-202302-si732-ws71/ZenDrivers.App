import 'package:zendrivers/shared/entities/like.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/environment.dart' as env;

class PostLikeService extends HttpService {
  static final _instance = PostLikeService._internal();
  PostLikeService._internal() : super(env.joinUrl("likes"));
  factory PostLikeService() => _instance;

  Future likePost(LikeRequest request) async => await post(body: request);
  Future deleteLikePost(int postId) async => await delete(append: "posts/$postId");
}