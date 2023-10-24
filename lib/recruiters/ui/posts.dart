import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:zendrivers/communication/entities/conversation.dart';
import 'package:zendrivers/communication/services/conversation.dart';
import 'package:zendrivers/communication/ui/inbox.dart';
import 'package:zendrivers/drivers/services/driver.dart';
import 'package:zendrivers/drivers/ui/drivers.dart';
import 'package:zendrivers/recruiters/entities/comment.dart';
import 'package:zendrivers/recruiters/entities/post.dart';
import 'package:zendrivers/recruiters/services/comment.dart';
import 'package:zendrivers/recruiters/services/post.dart';
import 'package:zendrivers/recruiters/services/recruiter.dart';
import 'package:zendrivers/recruiters/ui/post_create.dart';
import 'package:zendrivers/recruiters/ui/recruiters.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/fields.dart' as form;
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/preferences.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';
import 'package:zendrivers/shared/utils/environment.dart';

part 'post_actions.dart';
part 'post_comments.dart';

class PostView extends StatefulWidget {
  final Post post;
  final bool showComments;
  final bool? isDriver;
  final Function(Post, bool)? postClicked;
  final Function(Post, PostComment)? postCommented;
  final Function(Post, Post)? postEdited;
  final Function(Post)? postDeleted;

  const PostView({
    super.key,
    required this.post,
    required this.showComments,
    this.isDriver,
    this.postClicked,
    this.postCommented,
    this.postEdited,
    this.postDeleted
  });

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  late Post post;
  final _postService = PostService();
  final _actionsKey = GlobalKey<_PostActionsState>();
  LoginResponse get credentials => _postService.preferences.getCredentials();

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  Widget _publisherActions() => PopupMenuButton<String>(
    color: Colors.white,
    icon: const Icon(FluentIcons.more_horizontal_48_regular, color: Colors.black,),
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        value: 'delete',
        onTap: () => ZenDrivers.showDialog(
          context: context,
          dialog: AppDeleteConfirmDialog(
            deleteFuture: () async => _postService.deletePost(post.id),
            name: "post",
            afterDeleted: () {
              if(widget.postDeleted != null) {
                widget.postDeleted!(post);
              }
            },
          )
        ),
        child: const Text('Delete'),
      ),
      PopupMenuItem<String>(
        value: 'edit',
        onTap: () {
          Navegations.persistentTo(context, withNavBar: false, widget: PostCreateView(
            data: post,
          )).then((value) {
            if(value != null && value is Post && widget.postEdited != null) {
              widget.postEdited!(post, value);
              setState(() {
                post = value;
              });
            }
          });
        },
        child: const Text('Edit'),
      )
    ],
  );

  Widget _publisher(BuildContext context) => AppPadding.widget(
    padding: AppPadding.topAndBottom(value: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () => ListRecruiters.toRecruiterProfile(context, recruiter: post.recruiter),
          child: Row(
            children: <Widget>[
              ImageUtils.avatar(
                url: post.recruiter.account.imageUrl,
                radius: 16,
                padding: AppPadding.horAndVer(vertical: 4, horizontal: 2),
              ),
              Expanded(
                child: AppPadding.widget(
                  padding: AppPadding.leftAndRight(value: 4),
                  child: Text(
                    '${post.recruiter.account.firstname} ${post.recruiter.account.lastname}',
                    style: AppText.title,
                  )
                ),
              ),
              if(credentials.isRecruiter && credentials.username == post.recruiter.account.username && !widget.showComments)
                _publisherActions()
            ],
          ),
        ),
        Text(
          post.date.timeAgo(),
          style: AppText.comment,
        )
      ],
    )
  );

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
      padding: AppPadding.horAndVer(vertical: 4, horizontal: 4),
      child: Column(
        children: [
          Card(
            elevation: 2,
            child: AppPadding.widget(
              padding: AppPadding.leftAndRight(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _publisher(context),
                  AppPadding.widget(
                    padding: AppPadding.topAndBottom(value: 4),
                    child: Text(post.title, style: AppText.bold,)
                  ),
                  if(post.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageUtils.net(post.image!, errorBuilder: (context, object, stack) => const SizedBox()),
                    ),
                  AppPadding.widget(
                    padding: AppPadding.top(),
                    child: Text(
                      post.description,
                      style: AppText.paragraph,
                    ),
                  ),
                  _PostActions(
                    key: _actionsKey,
                    post: post,
                    showComments: widget.showComments,
                    clickCallback: widget.postClicked,
                    commentCallback: widget.postCommented,
                    isDriver: widget.isDriver,
                  )
                ],
              ),
            ),
          ),
          if(widget.showComments)
            _PostComments(post: post, actionsKey: _actionsKey,)
        ],
      ),
    );
  }
}
