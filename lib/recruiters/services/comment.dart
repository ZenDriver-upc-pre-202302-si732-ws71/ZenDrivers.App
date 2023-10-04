import 'package:zendrivers/recruiters/entities/comment.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart' as env;
import 'package:zendrivers/shared/utils/environment.dart';

class PostCommentService extends HttpService {
  static final _instance = PostCommentService._internal();
  PostCommentService._internal() : super(env.joinUrl("comments"));
  factory PostCommentService() => _instance;

  Future<PostComment> commentPost(PostCommentRequest request) async {
    final response = await post(body: request);
    if(!response.isCreated) {
      throw Exception(response.body);
    }

    return PostComment.fromRawJson(response.body);
  }
}