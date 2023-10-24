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

  Widget _nothingToShow() => Text("Nothing to show", style: AppText.paragraph,);

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
              _DriverExperiences(
                credentials: _credentials,
                driver: driver,
                nothing: _nothingToShow(),
              ),
              _DriverLicenses(
                credentials: _credentials,
                driver: driver,
                nothing: _nothingToShow(),
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
  final DriverExperienceService service;
  final void Function(DriverExperience) experienceDeleted;
  final bool permitDelete;

  DateFormat get _dateFormat => format ?? DateFormat('dd/MM/yyyy');
  const _DriverExperience({super.key, required this.experience, this.format, required this.service, required this.experienceDeleted, required this.permitDelete});

  @override
  Widget build(BuildContext context) {
    return AppTile(
      title: Row(
        children: [
          Expanded(child: Text(experience.description)),
          if(permitDelete)
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => ZenDrivers.showDialog(
              context: context,
              dialog: AppDeleteConfirmDialog(
                deleteFuture: () async => service.deleteExperience(experience.id),
                name: "experience",
                afterDeleted: () => experienceDeleted(experience),
              )
            ),
            icon: const Icon(FluentIcons.delete_48_regular),
          )
        ],
      ),
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

class _DriverExperiences extends StatefulWidget {
  final LoginResponse credentials;
  final Driver driver;
  final Widget nothing;
  const _DriverExperiences({super.key, required this.credentials, required this.driver, required this.nothing});

  @override
  State<_DriverExperiences> createState() => _DriverExperiencesState();
}

class _DriverExperiencesState extends State<_DriverExperiences> {

  LoginResponse get _credentials => widget.credentials;
  Driver get driver => widget.driver;
  final _formKey = GlobalKey<FormBuilderState>();
  final DriverExperienceService _driverExperienceService = DriverExperienceService();

  void _validateField(String? name, String? _) => _formKey.currentState?.fields[name]?.validate();

  Future<EntityResponse<DriverExperience>> _save(DateTime? start, DateTime? end) async {
    if(_formKey.currentState?.validate() ?? false) {
      if(start != null && end != null) {
        final fields = _formKey.currentState?.fields.map((key, value) => MapEntry(key, value.value));
        if(fields != null) {
          final request = DriverExperienceRequest(
              startDate: start,
              endDate: end,
              description: fields["description"]
          );

          return _driverExperienceService.save(request);
        }
      }
    }

    return EntityResponse.invalid(message: "Fill all required fields");
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =_credentials.isDriver && driver.account.username == _credentials.username;
    return Column(
      children: <Widget>[
        _InformationAdder(
          formKey: _formKey,
          title: "Work Experiences",
          permitAdd: isOwner,
          save: _save,
          onSuccess: (response) {
            AppToast.show(context, response.message);
            if(response.isValid) {
              setState(() {
                driver.experiences.add(response.value!);
              });
              Navegations.back(context);
            }
          },
          firstField: NamedTextField(
            padding: AppPadding.bottom(),
            name: "description",
            label: "Description",
            alignLabelWithHint: true,
            validators: [
              FormBuilderValidators.required()
            ],
            onChanged: _validateField,
          ),
        ),
        OverflowColumn(
          maxItems: 2,
          items: driver.experiences.isNotEmpty ? driver.experiences.map((e) =>
              _DriverExperience(
                key: ObjectKey(e),
                experience: e,
                service: _driverExperienceService,
                permitDelete: isOwner,
                experienceDeleted: (value) {
                  setState(() {
                    driver.experiences.remove(value);
                  });
                },
              )) : [widget.nothing],
        ),
      ],
    );
  }
}

class _DriverLicenses extends StatefulWidget {
  final LoginResponse credentials;
  final Driver driver;
  final Widget nothing;
  const _DriverLicenses({super.key, required this.credentials, required this.driver, required this.nothing});

  @override
  State<_DriverLicenses> createState() => _DriverLicensesState();
}

class _DriverLicensesState extends State<_DriverLicenses> {
  LoginResponse get _credentials => widget.credentials;
  Driver get driver => widget.driver;
  final LicenseCategoryService _categoryService = LicenseCategoryService();

  final _formKey = GlobalKey<FormBuilderState>();
  final _licenseService = LicenseService();

  Future<EntityResponse<License>> _save(DateTime? start, DateTime? end) async {
    if(_formKey.currentState?.validate() ?? false) {
      if(start != null && end != null) {
        final fields = _formKey.currentState?.fields.map((key, value) => MapEntry(key, value.value));
        if(fields != null) {
          final request = LicenseRequest(
              start: start,
              end: end,
              categoryId: (fields["categories"] as LicenseCategory).id
          );
          return _licenseService.create(request);
        }
      }
    }

    return EntityResponse.invalid(message: "Fill all the required fields");
  }

  @override
  Widget build(BuildContext context) {
    final isOwner =_credentials.isDriver && driver.account.username == _credentials.username;
    return Column(
      children: <Widget>[
        _InformationAdder(
          title: "Licenses",
          permitAdd: isOwner,
          formKey: _formKey,
          save: _save,
          minDays: 365,
          endLastDate: DateTime.now().add(const Duration(days: 365 * 10)),
          onSuccess: (response) {
            AppToast.show(context, response.message);
            if(response.isValid) {
              setState(() {
                driver.licenses.add(response.value!);
              });
              Navegations.back(context);
            }
          },
          firstField: RichFutureBuilder(
            future: _categoryService.getAll(),
            builder: (categories) {
              return AppDropdown(
                items: categories,
                padding: AppPadding.bottom(),
                onChange: (_) => _formKey.currentState?.fields["categories"]?.validate(),
                name: "categories",
                label: "Licence Type",
                hint: "Select a type",
                validator: FormBuilderValidators.required(errorText: "Select a type"),
                converter: (item) => DropdownMenuItem(value: item, child: Text(item.name)),
              );
            },
          ),
        ),
        OverflowColumn(
          maxItems: 2,
          items: driver.licenses.isNotEmpty ? driver.licenses.map((e) =>
              _DriverLicense(
                key: ObjectKey(e),
                license: e,
                service: _licenseService,
                onDeleted: (value) {
                  setState(() {
                    driver.licenses.remove(value);
                  });
                },
                permitDelete: isOwner,
              )
          ) : [widget.nothing],
        )
      ],
    );
  }
}



class _DriverLicense extends StatelessWidget {
  final License license;
  final DateFormat? format;
  DateFormat get _dateFormat => format ?? DateFormat('dd/MM/yyyy');
  final void Function(License) onDeleted;
  final LicenseService service;
  final bool permitDelete;
  const _DriverLicense({super.key, required this.license, this.format, required this.onDeleted, required this.service, required this.permitDelete});

  @override
  Widget build(BuildContext context) {
    return AppTile(
      title: Row(
        children: [
          Expanded(child: Text("Category: ${license.category.name}")),
          if(permitDelete)
          IconButton(
            onPressed: () => ZenDrivers.showDialog(
              context: context,
              dialog: AppDeleteConfirmDialog(
                deleteFuture: () async => service.deleteLicense(license.id),
                name: "license",
                afterDeleted: () => onDeleted(license),
              )
            ),
            icon: const Icon(FluentIcons.delete_48_regular),
          )
        ],
      ),
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

class _InformationAdder<Ty extends Object?> extends StatelessWidget {
  final String title;
  final bool permitAdd;
  final Widget firstField;
  final _startDate = MutableObject<DateTime?>(null);
  final _endDate = MutableObject<DateTime?>(null);
  final Future<Ty> Function(DateTime?, DateTime?) save;
  final void Function(Ty)? onSuccess;
  final GlobalKey<FormBuilderState> formKey;
  final int minDays;
  final DateTime? endLastDate;

  _InformationAdder({super.key,
    required this.title,
    this.permitAdd=false,
    required this.firstField,
    required this.save,
    this.onSuccess,
    required this.formKey,
    this.minDays = 90,
    this.endLastDate
  });

  String _minMessage() => "Min difference must be $minDays days";

  String? _endValidator(DateTime? date) {
    if(date != null && _startDate.value != null) {
      final difference = date.difference(_startDate.value!);
      return difference.inDays < minDays ? _minMessage() : null;
    }
    return null;
  }

  String? _startValidator(DateTime? date) {
    if(date != null && _endDate.value != null) {
      final difference = _endDate.value!.difference(date);
      return difference.inDays < minDays ? _minMessage() : null;
    }
    return null;
  }

  Widget _addDialog(BuildContext context) => AlertDialog(
    actions: [
      AppButton(
        onClick: () => Navegations.back(context),
        child: const Text("Cancel"),
      ),
      AppAsyncButton(
        future: () async => save(_startDate.value, _endDate.value),
        onSuccess: onSuccess,
        onError: (e) => AppToast.show(context, e.toString()),
        child: const Text("Save"),
      )
    ],
    content: FormBuilder(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          firstField,
          AppDatePicker(
            label: "Start date",
            onDateSelected: (date) => _startDate.value = date,
            padding: AppPadding.bottom(),
            lastDate: DateTime.now().subtract(Duration(days: minDays)),
            validators: [
              FormBuilderValidators.required(),
              _startValidator
            ],
          ),
          AppDatePicker(
            label: "End date",
            onDateSelected: (date) => _endDate.value = date,
            padding: AppPadding.bottom(),
            lastDate: endLastDate ?? DateTime.now(),
            validators: [
              FormBuilderValidators.required(),
              _endValidator
            ],
          )
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
        padding: AppPadding.leftAndRight(),
        child: Row(
          children: [
            Expanded(child: Text(title, style: AppText.title,)),
            IconButton(
              onPressed: () => ZenDrivers.showDialog(context: context, dialog: _addDialog(context)),
              icon: const Icon(FluentIcons.add_48_regular, color: Colors.black,),
            )
          ],
        )
    );
  }
}
