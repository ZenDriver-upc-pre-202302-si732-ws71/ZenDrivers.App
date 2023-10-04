import 'package:zendrivers/recruiters/entities/post.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/environment.dart' as env;

class PostService extends HttpService {

  static final _instance = PostService._internal();
  PostService._internal() : super(env.joinUrl("posts"));
  factory PostService() => _instance;

  Future<List<Post>> getAll() async => await iterableGet(converter: Post.fromJson);
  Future<MessageResponse> createPost(PostSave request) async => messageResponse(await post(body: request), "Post created successfully");
  Future<List<Post>> getFrom(String recruiterUsername) async => await iterableGet(converter: Post.fromJson, append: "recruiters/$recruiterUsername");

}