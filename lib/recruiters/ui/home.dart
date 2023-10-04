import 'package:flutter/material.dart';
import 'package:zendrivers/recruiters/entities/post.dart';
import 'package:zendrivers/recruiters/services/post.dart';
import 'package:zendrivers/recruiters/ui/posts.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/entities/like.dart';
import 'package:zendrivers/shared/services/like.dart';
import 'package:zendrivers/shared/utils/preferences.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';


class Home extends StatelessWidget {

  PostService get postService => PostService();
  PostLikeService get likeService => PostLikeService();
  AppPreferences get preferences => postService.preferences;
  LoginResponse get credentials => preferences.getCredentials();

  const Home({super.key});

  void clickPostLike(Post source, bool liked) async {
    if(liked) {
      await likeService.likePost(LikeRequest(postId: source.id));
    }
    else {
      await likeService.deleteLikePost(source.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ZenDrivers.sliverScroll(
        body: AppFutureBuilder(
          future: postService.getAll(),
          builder: (posts) {
            posts.addAll(List.filled(10, posts[0]));
            return SingleChildScrollView(
              child: Column(
                children: [
                  if(credentials.isRecruiter)
                    _ActionBar(credentials: credentials,),
                  if(credentials.isDriver)
                    AppPadding.widget(padding: AppPadding.topAndBottom(value: 3)),
                  ...posts.map((post) => PostView(
                    post: post,
                    postClicked: clickPostLike,
                    showComments: false,
                    isDriver: credentials.isDriver,
                  )),
                  AppPadding.widget()
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final LoginResponse credentials;
  const _ActionBar({super.key, required this.credentials});
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
                  decoration: AppDecorations.box(
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
