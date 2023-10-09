import 'package:flutter/material.dart';
import 'package:zendrivers/recruiters/entities/post.dart';
import 'package:zendrivers/recruiters/services/post.dart';
import 'package:zendrivers/recruiters/ui/posts.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/communication/entities/like.dart';
import 'package:zendrivers/communication/services/like.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/preferences.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';


class Home extends StatelessWidget {
  final PostService _postService = PostService();

  AppPreferences get _preferences => _postService.preferences;
  LoginResponse get _credentials => _preferences.getCredentials();
  final _postsKey = GlobalKey<_HomePostsState>();

  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZenDrivers.sliverScroll(
        body: RichFutureBuilder(
          future: _postService.getAll(),
          builder: (posts) {
            return RefreshIndicator(
              onRefresh: () async {
                _postsKey.currentState?.update(await _postService.getAll());
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if(_credentials.isRecruiter)
                      _ActionBar(credentials: _credentials,),
                    if(_credentials.isDriver)
                      AppPadding.widget(padding: AppPadding.topAndBottom(value: 3)),
                    _HomePosts(key: _postsKey, posts: posts,),
                    AppPadding.widget()
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HomePosts extends StatefulWidget {
  final List<Post> posts;
  const _HomePosts({super.key, required this.posts});

  @override
  State<_HomePosts> createState() => _HomePostsState();
}

class _HomePostsState extends State<_HomePosts> {
  final PostLikeService _likeService = PostLikeService();
  List<Post> _posts = [];
  LoginResponse get _credentials => _likeService.preferences.getCredentials();

  @override
  void initState() {
    super.initState();
    _posts = widget.posts;
    _sortPosts();
  }

  void _sortPosts() {
    _posts.sort((a, b) => b.date.compareTo(a.date));
  }

  void update(List<Post> posts) {
    _posts = posts;
    _sortPosts();
    setState(() {});
  }

  void _clickPostLike(Post source, bool liked) async {
    if(liked) {
      await _likeService.likePost(LikeRequest(postId: source.id));
    }
    else {
      await _likeService.deleteLikePost(source.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _posts.map((post) => PostView(
        post: post,
        postClicked: _clickPostLike,
        showComments: false,
        isDriver: _credentials.isDriver,
      )).toList(),
    );
  }
}


class _ActionBar extends StatelessWidget {
  final LoginResponse credentials;
  const _ActionBar({required this.credentials});
  void _toCreatePost() {

  }

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
      padding: AppPadding.top(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: ImageUtils.avatar(url: credentials.imageUrl)),
          Expanded(
            flex: 5,
            child: AppPadding.widget(
              padding: AppPadding.left(value: 2),
              child: InkWell(
                onTap: _toCreatePost,
                child: Container(
                  decoration: BoxDecorations.box(
                    color: Colors.grey.shade500
                  ),
                  padding: AppPadding.horAndVer(horizontal: 8, vertical: 4),
                  child: Text("Has a new recruiter post?",
                    style: AppText.title,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AppPadding.widget(padding: AppPadding.all(value: 0)),
          )
        ],
      ),
    );
  }
}
