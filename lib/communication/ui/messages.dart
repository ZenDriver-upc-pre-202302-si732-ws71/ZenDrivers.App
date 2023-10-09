part of "inbox.dart";

class _ConversationMessages extends StatefulWidget {
  final List<Message> messages;
  final SimpleAccount target;
  const _ConversationMessages({super.key, required this.messages, required this.target});
  @override
  State<_ConversationMessages> createState() => _ConversationMessagesState();
}

class _ConversationMessagesState extends State<_ConversationMessages> {
  List<Message> get _messages => widget.messages;
  SimpleAccount get _target => widget.target;
  final _messagesController = ScrollController();
  final _hourFormat = DateFormat("hh:mm a");
  final _yearFormat = DateFormat("MMMM dd, yyyy");
  final _dayFormat = DateFormat(DateFormat.WEEKDAY);

  void addNewMessage(Message message) => setState(() {
    _messages.add(message);
  });

  Widget _buildMessage(BuildContext context, Message message, bool nextIsOther) {
    final isUser = _target.username != message.account.username;
    final effectiveTextStyle = isUser ? AppText.paragraph.copyWith(color: Colors.white) : AppText.paragraph;
    return AppPadding.widget(
      padding: isUser ? AppPadding.right(value: 5) : AppPadding.left(value: 5),
      child: ChatBubble(
        clipper: isUser ? ChatBubbleClip.sender(last: nextIsOther) : ChatBubbleClip.receiver(last: nextIsOther),
        alignment: isUser ? Alignment.topRight : null,
        margin: nextIsOther ? AppPadding.bottom() : AppPadding.bottom(value: 2),
        backGroundColor: isUser ? Theme.of(context).colorScheme.primary : Colors.grey[350],
        elevation: 8,
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(message.content, style: effectiveTextStyle),
            Text(_hourFormat.format(message.date).toLowerCase(), style: AppText.comment.copyWith(color: effectiveTextStyle.color))
          ],
        ),
      ),
    );
  }

  Widget _messageDate(DateTime? previousDate, DateTime currentDate) {
    bool isDifferentDate = false;
    String effectiveDate = _yearFormat.format(currentDate);
    if(previousDate == null || (_yearFormat.format(previousDate) != effectiveDate)) {
      isDifferentDate = true;
      final difference = DateTime.now().difference(currentDate);
      if(difference.inHours <= 23) {
        effectiveDate = "Today";
      }
      else if(difference.inDays == 1) {
        effectiveDate = "Yesterday";
      }
      else if(difference.inDays <= 6) {
        effectiveDate = _dayFormat.format(currentDate);
      }
    }


    return isDifferentDate ? AppPadding.widget(
      padding: AppPadding.bottom(value: 5),
      child: Center(
        child: Container(
          decoration: BoxDecorations.search(radius: 18),
          padding: AppPadding.leftAndRight(value: 5),
          child: Text(effectiveDate,
            style: AppText.comment,
          ),
        ),
      ),
    ) : AppPadding.zeroWidget();
  }

  Iterable<Widget> _buildMessages(BuildContext context) {
    return _messages.asMap().entries.map((entry) {
      final actual = entry.value;
      final nextIndex = entry.key + 1;

      final isLastMessageOrDifferentUser =
          nextIndex == _messages.length ||
              actual.account.username != _messages[nextIndex].account.username;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _messageDate(entry.key == 0 ? null : _messages[entry.key - 1].date, actual.date),
          _buildMessage(context, actual, isLastMessageOrDifferentUser),
        ],
      );
    });
  }

  @override
  void initState() {
    super.initState();
    afterBuild(callback: () {
      _messagesController.jumpTo(_messagesController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _messagesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _messagesController,
      child: Column(
        children: <Widget>[
          AppPadding.widget(padding: AppPadding.top()),
          ..._buildMessages(context)
        ],
      ),
    );
  }
}

class _MessageSend extends StatefulWidget {
  final MessageRequest? Function() createRequest;
  final void Function(Message) afterSend;
  const _MessageSend({required this.createRequest, required this.afterSend});

  @override
  State<_MessageSend> createState() => _MessageSendState();
}

class _MessageSendState extends State<_MessageSend> {
  bool isSending = false;
  MessageRequest? Function() get _createMessage => widget.createRequest;
  void Function(Message) get _afterSend => widget.afterSend;
  final MessageService _messageService = MessageService();

  void _sendMessage() {
    final request = _createMessage();
    if(request == null) {
      return;
    }

    if(!isSending) {
      setState(() {
        isSending = true;
      });

      _messageService.send(request).then((value) {
        setState(() {
          isSending = false;
        });
        if(value == null) {
          AppToast.show(context, "The message wasn't there are problems with the server.");
          return;
        }
        _afterSend(value);
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isSending ? null : _sendMessage,
      icon: isSending ? const CircularProgressIndicator() : Icon(FluentIcons.send_32_filled, color: Theme.of(context).colorScheme.primary,),
    );
  }
}