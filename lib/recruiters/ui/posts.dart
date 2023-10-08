import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:zendrivers/communication/entities/conversation.dart';
import 'package:zendrivers/communication/services/conversation.dart';
import 'package:zendrivers/communication/ui/inbox.dart';
import 'package:zendrivers/drivers/services/driver.dart';
import 'package:zendrivers/drivers/ui/drivers.dart';
import 'package:zendrivers/recruiters/entities/comment.dart';
import 'package:zendrivers/recruiters/entities/post.dart';
import 'package:zendrivers/recruiters/entities/recruiter.dart';
import 'package:zendrivers/recruiters/services/comment.dart';
import 'package:zendrivers/recruiters/ui/profile.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/fields.dart' as form;
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/preferences.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

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

  Widget _toRecruiterProfileOnTap(BuildContext context, {required Widget child, required Recruiter recruiter}) => GestureDetector(
    onTap: () => Navegations.persistentTo(context,
        widget: RecruiterProfile(recruiter: recruiter),
    ),
    child: child,
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
                  AppPadding.widget(
                    padding: AppPadding.topAndBottom(value: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _toRecruiterProfileOnTap(context,
                          recruiter: post.recruiter,
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
                  ),
                  AppPadding.widget(
                    padding: AppPadding.topAndBottom(value: 4),
                    child: Text(post.title, style: AppText.bold,)
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ImageUtils.net(post.image),
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
class _PostActions extends StatefulWidget {
  final Post post;
  final bool showComments;
  final bool? isDriver;
  final Function(Post, bool)? clickCallback;
  final Function(Post post, PostComment comment)? commentCallback;
  const _PostActions({
    super.key,
    required this.post,
    required this.showComments,
    this.isDriver,
    this.clickCallback,
    this.commentCallback
  });

  @override
  State<_PostActions> createState() => _PostActionsState();
}



class _PostActionsState extends State<_PostActions> {
  bool isLiked = false;
  final preferences = AppPreferences();
  LoginResponse get credentials => preferences.getCredentials();
  final _conversationService = ConversationService();

  Post get post => widget.post;
  bool get showComments => widget.showComments;
  bool? get isDriver => widget.isDriver;

  PostLike? postLike;
  bool get hasLike => postLike != null;

  Function(Post, bool)? get clickCallback => widget.clickCallback;
  Function(Post, PostComment)? get commentCallback => widget.commentCallback;
  bool get hasClickCallback => clickCallback != null;
  bool get hasCommentsCallback => commentCallback != null;

  void update() => setState(() {});

  void _like() {
    if(isLiked) {
      post.likes.remove(postLike!);
    }
    else {
      post.likes.add(postLike!);
    }
  }

  void _showComments() {
    Navegations.persistentTo(context,
      widget: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navegations.back(context);
              update();
            },
          ),
        ),
        body: SingleChildScrollView(child: PostView(post: post, showComments: true)),
      )
    );
  }


  List<Widget> _optionsRow() {
    final widgets = <Widget> [
      IconButton(
        icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : null,
        ),
        onPressed: () {
          setState(() {
            if(hasLike) {
              _like();
            }
            else {
              postLike = PostLike(id: -1, account: post.recruiter.account, postId: post.id);
              _like();
            }
            isLiked = !isLiked;
          });
          if(hasClickCallback) {
            clickCallback!(post, isLiked);
          }
        },
      ),
      Text("${post.likes.length} likes")
    ];

    if(!showComments) {
      widgets.add(IconButton(
        icon: const Icon(FluentIcons.comment_28_regular),
        onPressed: _showComments,
      ));
      widgets.add(GestureDetector(
        onTap: _showComments,
        child: Text("${post.comments.length} comments", style: AppText.paragraph,),
      ));
    }
    else {
      widgets.add(AppPadding.widget(
        padding: AppPadding.leftAndRight(value: 4),
        child: Text("${post.comments.length} comments", style: AppText.paragraph)
      ));
    }
    
    if(isDriver ?? false) {
      widgets.add(_contactRecruiter());
    }
  
    return widgets;
  }

  Widget _contactRecruiter() {
    final target = post.recruiter.account;
    final request = ConversationRequest(firstUsername: credentials.username, secondUsername: target.username);

    return SizedBox(
      height: 30,
      child: AppAsyncButton(
        future: () => _conversationService.getByUsernames(request),
        squareDimension: 18,
        child: const Text("Apply"),
        onSuccess: (value) {
          Inbox.toConversationView(context,
            target: target,
            conversation: value ?? Conversation(id: 0, sender: credentials.toSimpleAccount(), receiver: target, messages: []),
            initialMessage: "Hello, ${target.firstname}, I want to know more about the post \"${post.title}\""
          );
        },
      ),
    );
  }


  @override
  void initState() {
    super.initState();

    isLiked = post.likes.any((element) {
      final isLiked = element.account.username == credentials.username;
      if(isLiked) {
        postLike = element;
      }
      return isLiked;
    });
  }

  @override
  Widget build(BuildContext context) => Row(children: _optionsRow(),);
}

class _PostComments extends StatefulWidget {
  final Post post;
  final GlobalKey<_PostActionsState> actionsKey;
  const _PostComments({required this.post, required this.actionsKey});

  @override
  State<_PostComments> createState() => _PostCommentsState();
}

class _PostCommentsState extends State<_PostComments> {
  List<PostComment> get comments => post.comments;
  Post get post => widget.post;
  GlobalKey<_PostActionsState> get actionsKey => widget.actionsKey;
  final _driverService = DriverService();

  bool isSending = false;
  bool isSearchingDriver = false;
  final TextEditingController _commentController = TextEditingController();
  final PostCommentService _postCommentService = PostCommentService();

  void _toDriverProfile(SimpleAccount account) {
    if(!isSearchingDriver) {
      isSearchingDriver = true;
      andThen(_driverService.findByUsername(account.username), then: (value) {
        if(value != null) {
          isSearchingDriver = false;
          ListDriver.toDriverView(context, value);
        } else {
          AppToast.show(context, "Invalid username");
        }
      });
    }
  }


  Widget _buildComment(PostComment comment) => AppTile(
    onTap: comment.account.isDriver ? () => _toDriverProfile(comment.account) : null,
    padding: AppPadding.horAndVer(vertical: 4),
    subtitle: Text(comment.content),
    leading: ImageUtils.avatar(url: comment.account.imageUrl),
    trailing: Text(comment.date.timeAgo()),
    title: Row(
      children: <Widget>[
        Text(
          "${comment.account.firstname} ${comment.account.lastname}",
          style: AppText.bold,
        ),
        AppPadding.widget(
          padding: AppPadding.left(),
          child: Text(roleToString(comment.account.role), style: AppText.comment,)
        )
      ],
    ),
  );

  void _comment() {
    if(_commentController.text.isNotEmpty) {
      setState(() {
        isSending = true;
      });
      final request = PostCommentRequest(content: _commentController.text, postId: post.id);
      andThen(_postCommentService.commentPost(request), then: (response) {
        setState(() {
          post.comments.add(response);
          actionsKey.currentState?.update();
          isSending = false;
        });
      });
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        form.TextField(
          name: "comment",
          padding: AppPadding.horAndVer(),
          controller: _commentController,
          showLabel: false,
          suffixIcon: IconButton(
            icon: isSending ? const CircularProgressIndicator.adaptive() : const Icon(Icons.send_outlined),
            onPressed: isSending ? null : _comment,
          ),
        ),
        OverflowColumn(
          maxItems: 5,
          items: comments.map((e) => _buildComment(e)),
        ),
        AppPadding.widget()
      ],
    );
  }
}

