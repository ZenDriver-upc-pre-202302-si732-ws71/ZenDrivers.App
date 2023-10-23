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
import 'package:zendrivers/recruiters/services/recruiter.dart';
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

class PostView extends StatelessWidget {
  final Post post;
  final bool showComments;
  final bool? isDriver;
  final Function(Post, bool)? postClicked;
  final Function(Post, PostComment)? postCommented;
  final _actionsKey = GlobalKey<_PostActionsState>();
  PostView({
    super.key,
    required this.post,
    required this.showComments,
    this.isDriver,
    this.postClicked,
    this.postCommented
  });


  Widget _publisher(BuildContext context) => AppPadding.widget(
    padding: AppPadding.topAndBottom(value: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () => ListRecruiters.toRecruiterProfile(context, recruiter: post.recruiter),
          child: Row(
            children: <Widget>[
              ImageUtils.avatar(
                url: post.recruiter.account.imageUrl,
                radius: 16,
                padding: AppPadding.horAndVer(vertical: 4, horizontal: 2)
              ),
              AppPadding.widget(
                padding: AppPadding.leftAndRight(value: 4),
                child: Text(
                  '${post.recruiter.account.firstname} ${post.recruiter.account.lastname}',
                  style: AppText.title,
                )
              )
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
                      child: ImageUtils.net(post.image!),
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
                    showComments: showComments,
                    clickCallback: postClicked,
                    commentCallback: postCommented,
                    isDriver: isDriver,
                  )
                ],
              ),
            ),
          ),
          if(showComments)
            _PostComments(post: post, actionsKey: _actionsKey,)
        ],
      ),
    );
  }
}




