part of "inbox.dart";

class _Conversations extends StatefulWidget {
  final LoginResponse credentials;
  final ConversationService service;
  const _Conversations({super.key, required this.credentials, required this.service});

  @override
  State<_Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends State<_Conversations> {
  LoginResponse get _credentials => widget.credentials;
  ConversationService get _service => widget.service;
  List<Conversation> _conversations = [];
  String _findRequest = "";

  void _updateConversations(List<Conversation> value) {
    if(value.isNotEmpty) {
      setState(() {
        _conversations = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    andThen(_service.getAllByUsername(_credentials.username), then: _updateConversations);
  }

  Widget _lastMessage(Message message, SimpleAccount account) {
    final effectiveText = (message.account.username == account.username ? "" : "You: ") + message.content;
    return Text(effectiveText,
      style: AppText.paragraph,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  void search(String? request) {
    setState(() {
      _findRequest = request?.toLowerCase() ?? "";
    });
  }

  Iterable<Conversation> _filter() {
    if(_findRequest.isNotEmpty) {
      return _conversations.where((value) {
        final effectiveAccount = value.sender.username == _credentials.username ? value.receiver : value.sender;
        return effectiveAccount.firstname.toLowerCase().contains(_findRequest)
            || effectiveAccount.lastname.toLowerCase().contains(_findRequest);
      });
    }
    return _conversations;
  }

  Future<void> update() async => _updateConversations(await _service.getAllByUsername(_credentials.username));

  Widget _buildConversation(BuildContext context, Conversation conversation) {
    final effectiveShowAccount = conversation.sender.username == _credentials.username ? conversation.receiver : conversation.sender;
    return AppTile(
      onTap: () => Inbox.toConversationView(context,
          target: effectiveShowAccount,
          conversation: conversation,
          onBackConversation: () => search(null)
      ),
      leading: ImageUtils.avatar(url: effectiveShowAccount.imageUrl),
      title: Row(
        children: <Widget>[
          Text("${effectiveShowAccount.firstname} ${effectiveShowAccount.lastname}", style: AppText.bold,),
          AppPadding.widget(
              padding: AppPadding.left(value: 4),
              child: Text(roleToString(effectiveShowAccount.role), style: AppText.comment,)
          )
        ],
      ),
      subtitle: conversation.messages.isNotEmpty ? _lastMessage(conversation.messages.last, effectiveShowAccount) : null,
      trailing: conversation.messages.isNotEmpty ? Text(conversation.messages.last.date.timeAgo(), style: AppText.comment,) : null,
    );
  }
  @override
  Widget build(BuildContext context) => Column(
    children: _filter().map((e) => _buildConversation(context, e)).toList(),
  );
}

class _ConversationView extends StatelessWidget {
  final Conversation conversation;
  final SimpleAccount target;
  final GlobalKey<_ConversationMessagesState> _messagesKey = GlobalKey();
  final TextEditingController _messageController = TextEditingController();
  final void Function()? onBackConversation;
  final String? initialMessage;

  final _recruiterService = RecruiterService();
  final _driverService = DriverService();

  final _isToProfile = MutableObject(false);

  _ConversationView({required this.conversation, required this.target, this.onBackConversation, this.initialMessage}) {
    if(initialMessage != null) {
      _messageController.text = initialMessage!;
    }
  }

  void _toProfile(BuildContext context) {
    if(!_isToProfile.value) {
      _isToProfile.value = true;
      if(target.isRecruiter) {
        andThen(_recruiterService.getByUsername(target.username), then: (value) {
          _isToProfile.value = false;
          if(value != null) {
            ListRecruiters.toRecruiterProfile(context, recruiter: value, companyAction: false);
          }
        });
      }
      else if(target.isDriver) {
        andThen(_driverService.findByUsername(target.username), then: (value) {
          _isToProfile.value = false;
          if(value != null) {
            ListDrivers.toDriverView(context, value, showContact: false);
          }
        });
      }

      Timer(const Duration(seconds: 4), () {
        if(_isToProfile.value) {
          _isToProfile.value = false;
        }
      });
    }
  }

  MessageRequest? _createMessage() {
    if(_messageController.text.isEmpty) {
      return null;
    }

    final request = MessageRequest(content: _messageController.text, receiverUsername: target.username);
    _messageController.clear();
    return request;
  }

  void _backConversationCallback() {
    if(onBackConversation != null) {
      onBackConversation!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context,
        leading: ZenDrivers.back(context,
            onPressed: () {
              _backConversationCallback();
              Navegations.back(context);
            }
        ),
        widTitle: Row(
          children: <Widget>[
            ImageUtils.avatar(url: target.imageUrl),
            AppPadding.widget(
                child: Text("${target.firstname} ${target.lastname}",
                  style: AppText.bold.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
            )
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                onTap: () => _toProfile(context),
                child: const Text('View profile'),
              )
            ],
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _ConversationMessages(
              key: _messagesKey,
              messages: conversation.messages,
              target: target,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: AppPadding.widget(
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5),
                  child: Container(
                    decoration: BoxDecorations.search(radius: 20),
                    child: fields.TextField(
                      controller: _messageController,
                      padding: AppPadding.horAndVer(horizontal: 10, vertical: 0),
                      keyboardType: TextInputType.multiline,
                      name: "send",
                      hint: "Type here your message",
                      showLabel: false,
                      enableBorder: InputBorder.none,
                      border: InputBorder.none,
                      maxLines: 3,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
              ),
              _MessageSend(
                createRequest: _createMessage,
                afterSend: (message) => _messagesKey.currentState?.addNewMessage(message),
              )
            ],
          ),
          AppPadding.widget(padding: AppPadding.top(value: 4))
        ],
      ),
    );
  }
}