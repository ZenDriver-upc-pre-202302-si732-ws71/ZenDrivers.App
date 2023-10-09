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

  bool isSending = false;
  final TextEditingController _commentController = TextEditingController();
  final PostCommentService _postCommentService = PostCommentService();

  void _toDriverProfile(SimpleAccount account) {
    andThen(_driverService.findByUsername(account.username), then: (value) {
      if(value != null) {
        ListDrivers.toDriverView(context, value);
      } else {
        AppToast.show(context, "Invalid username");
      }
    });
  }
  void _toRecruiterProfile(SimpleAccount account) {

  }

  void _onTapComment(SimpleAccount commentAccount) {
    if(commentAccount.isDriver) {
      _toDriverProfile(commentAccount);
    }
    else if(commentAccount.isRecruiter) {
      _toRecruiterProfile(commentAccount);
    }
  }


  Widget _buildComment(PostComment comment) => AppTile(
    onTap: () => _onTapComment(comment.account),
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