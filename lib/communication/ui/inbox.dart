
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:zendrivers/communication/entities/conversation.dart';
import 'package:zendrivers/communication/entities/message.dart';
import 'package:zendrivers/communication/services/conversation.dart';
import 'package:zendrivers/communication/services/message.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';
import 'package:zendrivers/shared/utils/fields.dart' as fields;

class Inbox extends StatelessWidget {
  final ConversationService _conversationService = ConversationService();
  LoginResponse get _credentials => _conversationService.preferences.getCredentials();
  final GlobalKey<_ConversationsState> _conversationsKey = GlobalKey();

  Inbox({super.key});

  static void toConversationView(BuildContext context, {
    required SimpleAccount target,
    required Conversation conversation,
    void Function()? onBackConversation,
    String? initialMessage
  }) {
    Navegations.persistentTo(context,
        _ConversationView(
          conversation: conversation,
          target: target,
          onBackConversation: onBackConversation,
          initialMessage: initialMessage,
        ),
      withNavBar: false
    );
  }


  void _search(String name, String? value) => _conversationsKey.currentState?.search(value);

  @override
  Widget build(BuildContext context) {
    return ZenDrivers.sliverScroll(
      body: RefreshIndicator(
        onRefresh: () async => await _conversationsKey.currentState?.update(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppFutureBuilder(
                future: _conversationService.getAllByUsername(_credentials.username),
                builder: (conversations) => Column(
                  children: [
                    AppPadding.widget(
                      child: Row(
                        children: <Widget>[
                          ImageUtils.avatar(
                            url: _credentials.imageUrl,
                            padding: AppPadding.right()
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecorations.search(),
                              child: fields.TextField(
                                name: "search",
                                onChanged: _search,
                                border: InputBorder.none,
                                enableBorder: InputBorder.none,
                                showLabel: false,
                                prefixIcon: const Icon(FluentIcons.search_28_regular),
                              ),
                            ),
                          )
                        ],
                      )
                    ),
                    _Conversations(
                      key: _conversationsKey,
                      credentials: _credentials,
                      service: _conversationService,
                    )
                  ],
                ),
              ),
              AppPadding.widget(padding: AppPadding.top())
            ],
          ),
        ),
      )
    );
  }
}


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

  _ConversationView({required this.conversation, required this.target, this.onBackConversation, this.initialMessage}) {
    if(initialMessage != null) {
      _messageController.text = initialMessage!;
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
        )
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
                      name: "send",
                      hint: "Write a message",
                      showLabel: false,
                      enableBorder: InputBorder.none,
                      border: InputBorder.none,
                      maxLines: null,
                    ),
                  ),
                ),
              ),
              _MessageSend(
                createRequest: _createMessage,
                afterSend: (message) => _messagesKey.currentState?.addNewMessage(message),
              )
            ],
          )
        ],
      ),
    );
  }
}


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

  void addNewMessage(Message message) => setState(() {
    _messages.add(message);
  });

  Widget _space() => Expanded(flex: 2,child: AppPadding.zeroWidget(),);

  Widget _buildMessage(Message message) {
    final isUser = _target.username != message.account.username;
    return Row(
      children: <Widget>[
        if(isUser)
          _space(),
        Expanded(
          flex: 6,
          child: AppPadding.widget(
            padding: AppPadding.horAndVer(vertical: 4),
            child: Container(
              padding: AppPadding.horAndVer(vertical: 5),
              decoration: BoxDecorations.search(radius: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(message.content, style: AppText.paragraph,),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: AppPadding.widget(
                      padding: AppPadding.top(value: 4),
                      child: Text(message.date.timeAgo(),
                        style: AppText.comment,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        if(!isUser)
          _space()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          AppPadding.widget(padding: AppPadding.top()),
          ..._messages.map((e) => _buildMessage(e))
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

      andThen(_messageService.send(request), then: (value) {
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
      icon: isSending ? const CircularProgressIndicator() : const Icon(FluentIcons.send_32_regular),
    );
  }
}
