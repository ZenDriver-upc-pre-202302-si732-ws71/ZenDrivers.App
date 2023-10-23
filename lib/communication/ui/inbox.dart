
import 'dart:async';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:zendrivers/communication/entities/conversation.dart';
import 'package:zendrivers/communication/entities/message.dart';
import 'package:zendrivers/communication/services/conversation.dart';
import 'package:zendrivers/communication/services/message.dart';
import 'package:zendrivers/drivers/services/driver.dart';
import 'package:zendrivers/drivers/ui/drivers.dart';
import 'package:zendrivers/recruiters/services/recruiter.dart';
import 'package:zendrivers/recruiters/ui/recruiters.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/validators.dart';
import 'package:zendrivers/shared/utils/widgets.dart';
import 'package:zendrivers/shared/utils/fields.dart' as fields;

part 'conversations.dart';
part 'messages.dart';

class Inbox extends StatelessWidget {
  final ConversationService _conversationService = ConversationService();
  final _conversationsKey = GlobalKey<_ConversationsState>();
  final GlobalKey<SearchBarState>? searchKey;
  LoginResponse get _credentials => _conversationService.preferences.getCredentials();

  Inbox({super.key, this.searchKey});

  static void toConversationView(BuildContext context, {
    required SimpleAccount target,
    required Conversation conversation,
    void Function()? onBackConversation,
    String? initialMessage
  }) {
    Navegations.persistentTo(context,
      widget: _ConversationView(
        conversation: conversation,
        target: target,
        onBackConversation: onBackConversation,
        initialMessage: initialMessage,
      ),
      withNavBar: true
    );
  }


  void _searchRequest(String name, String? value) => _conversationsKey.currentState?.search(value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context),
      body: Column(
        children: [
          Expanded(
            child: RichFutureBuilder(
              future: _conversationService.getAllByUsername(_credentials.username),
              builder: (conversations) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _conversationsKey.currentState?.update(await _conversationService.getAllByUsername(_credentials.username));
                  },
                  child: Column(
                    children: [
                      SearchBar(
                        key: searchKey,
                        credentials: _credentials,
                        search: _searchRequest,
                      ),
                      Expanded(
                        child: _Conversations(
                          key: _conversationsKey,
                          credentials: _credentials,
                          conversations: conversations,
                        ),
                      ),
                      AppPadding.widget(padding: AppPadding.bottom())
                    ],
                  ),
                );
              },
            ),
          ),
          AppPadding.widget(padding: AppPadding.top())
        ],
      )
    );
  }
}

class SearchBar extends StatefulWidget {
  final LoginResponse credentials;
  final Function(String, String?) search;
  const SearchBar({super.key, required this.credentials, required this.search});

  @override
  State<SearchBar> createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  LoginResponse get _credentials => widget.credentials;
  void Function(String, String?) get _searchRequest => widget.search;

  void update() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
        child: Row(
          children: <Widget>[
            ImageUtils.avatar(
              url: _credentials.imageUrl,
              padding: AppPadding.right()
            ),
            Expanded(
              child: Container(
                decoration: BoxDecorations.search(),
                child: fields.NamedTextField(
                  name: "search",
                  onChanged: _searchRequest,
                  border: InputBorder.none,
                  enableBorder: InputBorder.none,
                  showLabel: false,
                  prefixIcon: const Icon(FluentIcons.search_28_regular),
                ),
              ),
            )
          ],
        )
    );
  }
}


