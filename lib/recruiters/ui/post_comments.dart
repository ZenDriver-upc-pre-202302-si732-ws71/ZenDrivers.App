part of 'posts.dart';
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
  final _recruiterService = RecruiterService();
  bool isSending = false;
  final TextEditingController _commentController = TextEditingController();
  final PostCommentService _postCommentService = PostCommentService();
  final _commentsKey = GlobalKey<OverflowColumnState>();


  void _toDriverProfile(SimpleAccount account) {
    _driverService.findByUsername(account.username).then((value) {
      if(value != null) {
        ListDrivers.toDriverView(context, value);
      } else {
        AppToast.show(context, "Invalid username");
      }
    });
  }

  void _toRecruiterProfile(SimpleAccount account) {
   _recruiterService.getByUsername(account.username).then((value) {

    });
  }

  void _onCommentTap(SimpleAccount commentAccount) {
    if(commentAccount.isDriver) {
      _toDriverProfile(commentAccount);
    }
    else if(commentAccount.isRecruiter) {
      _toRecruiterProfile(commentAccount);
    }
  }

  Widget _buildComment(PostComment comment) => AppTile(
    onTap: () => _onCommentTap(comment.account),
    padding: AppPadding.horAndVer(vertical: 4),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(comment.content),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(comment.date.timeAgo(), style: AppText.comment,),
        )
      ],
    ),
    leading: ImageUtils.avatar(url: comment.account.imageUrl),
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
      _postCommentService.commentPost(request).then((response) {
        setState(() {
          post.comments.insert(0, response);
          actionsKey.currentState?.update();
          _commentsKey.currentState?.update(length: post.comments.length);
          isSending = false;
        });
      });
      _commentController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _sortComments();
  }

  void _sortComments() {
    post.comments.sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppPadding.widget(
          padding: AppPadding.topAndBottom(value: 5),
          child: Container(
            decoration: BoxDecorations.search(radius: 15),
            child: form.TextField(
              name: "comment",
              padding: AppPadding.left(),
              controller: _commentController,
              showLabel: false,
              border: InputBorder.none,
              enableBorder: InputBorder.none,
              suffixIcon: IconButton(
                icon: isSending ? const CircularProgressIndicator.adaptive() : Icon(FluentIcons.send_28_filled, color: Theme.of(context).colorScheme.primary,),
                onPressed: isSending ? null : _comment,
              ),
              maxLines: 2,
              minLines: 1,
              keyboardType: TextInputType.multiline,
            ),
          ),
        ),
        OverflowColumn(
          key: _commentsKey,
          maxItems: 5,
          items: comments.map((e) => _buildComment(e)),
        ),
        AppPadding.widget()
      ],
    );
  }
}