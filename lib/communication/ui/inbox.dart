import 'dart:async';

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
    required LoginResponse credentials,
    required Conversation conversation,
  }) {
    Navegations.persistentTo(context, _ConversationView(
        conversation: conversation,
        credentials: credentials,
      ),
      withNavBar: false
    );
  }


  void _search(String name, String? value) => _conversationsKey.currentState?.search(value);

  @override
  Widget build(BuildContext context) {
    return ZenDrivers.sliverScroll(
      body: SingleChildScrollView(
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
                    conversations: conversations,
                  )
                ],
              ),
            ),
            AppPadding.widget(padding: AppPadding.top())
          ],
        ),
      )
    );
  }
}


class _Conversations extends StatefulWidget {
  final LoginResponse credentials;
  final List<Conversation> conversations;
  const _Conversations({super.key, required this.credentials, required this.conversations});

  @override
  State<_Conversations> createState() => _ConversationsState();
}

class _ConversationsState extends State<_Conversations> {
  LoginResponse get _credentials => widget.credentials;
  List<Conversation> get conversations => widget.conversations;
  String _findRequest = "";

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
      return conversations.takeWhile((value) {
        final effectiveAccount = value.sender.username == _credentials.username ? value.receiver : value.sender;
        return effectiveAccount.firstname.toLowerCase().contains(_findRequest)
            || effectiveAccount.lastname.toLowerCase().contains(_findRequest);
      });
    }
    return conversations;
  }

  Widget _buildConversation(BuildContext context, Conversation conversation) {
    final effectiveShowAccount = conversation.sender.username == _credentials.username ? conversation.receiver : conversation.sender;
    return AppTile(
      onTap: () => Inbox.toConversationView(context,
        credentials: _credentials,
        conversation: conversation
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
  final LoginResponse credentials;
  final GlobalKey<_ConversationMessagesState> _messagesKey = GlobalKey();
  final TextEditingController _messageController = TextEditingController();

  _ConversationView({required this.conversation, required this.credentials});

  MessageRequest? _createMessage() {
    if(_messageController.text.isEmpty) {
      return null;
    }

    final effectiveTarget = conversation.sender.username == credentials.username ? conversation.receiver : conversation.sender;
    final request = MessageRequest(content: _messageController.text, receiverUsername: effectiveTarget.username);
    _messageController.clear();
    return request;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context,
        leading: ZenDrivers.back(context),
        widTitle: Row(
          children: <Widget>[
            ImageUtils.avatar(url: credentials.imageUrl),
            AppPadding.widget(
              child: Text("${credentials.firstname} ${credentials.lastname}",
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
            child: SingleChildScrollView(
              child: _ConversationMessages(
                key: _messagesKey,
                messages: conversation.messages,
                credentials: credentials,
              ),
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
  final LoginResponse credentials;
  const _ConversationMessages({super.key, required this.messages, required this.credentials});
  @override
  State<_ConversationMessages> createState() => _ConversationMessagesState();
}

class _ConversationMessagesState extends State<_ConversationMessages> {
  List<Message> get _messages => widget.messages;
  LoginResponse get _credentials => widget.credentials;

  void addNewMessage(Message message) => setState(() {
    _messages.add(message);
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _MessageSend extends StatefulWidget {
  final MessageRequest? Function() createRequest;
  final void Function(Message) afterSend;
  const _MessageSend({super.key, required this.createRequest, required this.afterSend});

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
      Timer(const Duration(seconds: 2), () {
        setState(() {
          isSending = false;
        });
      });
      /*
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
      * */
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
