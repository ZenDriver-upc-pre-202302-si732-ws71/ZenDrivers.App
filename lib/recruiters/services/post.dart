import 'package:zendrivers/recruiters/entities/post.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class PostService extends HttpService {

  static final _instance = PostService._internal();
  PostService._internal() : super(ZenDrivers.joinUrl("posts"));
  factory PostService() => _instance;

  Future<List<Post>> getAll() async => await iterableGet(converter: Post.fromJson);
  Future<EntityResponse<Post>> createPost(PostSave request) async {
    final response = await post(body: request);
    return response.isCreated ? EntityResponse(Post.fromRawJson(response.body)) : EntityResponse.invalid();
  }
  Future<List<Post>> getFrom(String recruiterUsername) async => await iterableGet(converter: Post.fromJson, append: "recruiters/$recruiterUsername");

}