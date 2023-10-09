part of 'posts.dart';

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
            backgroundColor: /*Theme.of(context).colorScheme.secondary*/Colors.transparent,
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