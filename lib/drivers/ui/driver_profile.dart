part of 'drivers.dart';

class DriverProfile extends StatelessWidget {
  final Driver driver;
  final ConversationService _conversationService = ConversationService();
  LoginResponse get _credentials => _conversationService.preferences.getCredentials();
  final bool showContact;

  DriverProfile({super.key, required this.driver, this.showContact = true});

  String _contactMessage(LoginResponse credentials, SimpleAccount target) {
    if(credentials.isDriver){
      return "Hey, ${target.firstname}, how are you?";
    }

    return "Hello, ${target.firstname}, do you want to work with our company?";
  }

  Widget _contactDriver(BuildContext context) {
    final credentials = _credentials;
    final request = ConversationRequest(firstUsername: credentials.username, secondUsername: driver.account.username);

    return AppAsyncButton(
      future: () => _conversationService.getByUsernames(request),
      child: const Text("Contact"),
      onSuccess: (value) {
        Inbox.toConversationView(context,
            target: driver.account,
            conversation: value ?? Conversation(id: 0, sender: credentials.toSimpleAccount(), receiver: driver.account, messages: []),
            initialMessage: _contactMessage(credentials, driver.account)
        );
      },
    );
  }

  List<Widget> _nothingToShow() => [Text("Nothing to show", style: AppText.paragraph,)];

  Widget _showTextField(String text) => ShowField(
    text: AppPadding.widget(
        padding: AppPadding.horAndVer(vertical: 5),
        child: Text(text,
          style: AppText.paragraph,
        )
    ),
    background: Colors.white,
    padding: AppPadding.right(),
  );

  Widget _showFieldSpacer() =>  AppPadding.widget(padding: AppPadding.topAndBottom(value: 5));

  Widget _presentation(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.primary,
    elevation: 1,
    child: Row(
      children: <Widget>[
        Expanded(
          child: ZenDrivers.profile(driver.account.imageUrl ?? ZenDrivers.defaultProfileUrl,
              padding: AppPadding.horAndVer(horizontal: 6)
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              _showFieldSpacer(),
              _showTextField(driver.account.firstname),
              _showFieldSpacer(),
              _showTextField(driver.account.lastname),
              _showFieldSpacer(),
              _showTextField(driver.account.phone),
              _showFieldSpacer(),
              if(_credentials.isRecruiter && showContact)
                _contactDriver(context)
            ],
          ),
        )
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context,
        leading: ZenDrivers.back(context),
        title: "${driver.account.firstname}'s profile"
      ),
      body: SingleChildScrollView(
        child: AppPadding.widget(
          padding: AppPadding.horAndVer(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _presentation(context),
              AppPadding.widget(
                  padding: AppPadding.leftAndRight(),
                  child: Text("Work Experiences", style: AppText.title,)
              ),
              OverflowColumn(
                maxItems: 2,
                items: driver.experiences.isNotEmpty ? driver.experiences.map((e) => _DriverExperience(experience: e)) : _nothingToShow(),
              ),
              AppPadding.widget(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text("Licenses", style: AppText.title,)
              ),
              OverflowColumn(
                maxItems: 2,
                items: driver.licenses.isNotEmpty ? driver.licenses.map((e) => _DriverLicense(license: e)) : _nothingToShow(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _DriverExperience extends StatelessWidget {
  final DriverExperience experience;
  final DateFormat? format;
  DateFormat get _dateFormat => format ?? DateFormat('dd/MM/yyyy');
  const _DriverExperience({required this.experience, this.format});

  @override
  Widget build(BuildContext context) {
    return AppTile(
      title: Text(experience.description),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Text("From: ${_dateFormat.format(experience.startDate)}"),
          ),
          Expanded(
            child: Text("To: ${_dateFormat.format(experience.endDate)}"),
          )
        ],
      ),
    );
  }
}

class _DriverLicense extends StatelessWidget {
  final License license;
  final DateFormat? format;
  DateFormat get _dateFormat => format ?? DateFormat('dd/MM/yyyy');
  const _DriverLicense({required this.license, this.format});

  @override
  Widget build(BuildContext context) {
    return AppTile(
      title: Text("Category: ${license.category.name}"),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Text("From: ${_dateFormat.format(license.start)}"),
          ),
          Expanded(
            child: Text("To: ${_dateFormat.format(license.end)}"),
          )
        ],
      ),
    );
  }
}