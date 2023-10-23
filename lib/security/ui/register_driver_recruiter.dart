part of 'register_fields.dart';

class _RecruiterOrDriverForm extends StatefulWidget {

  final TextEditingController emailController;
  final TextEditingController descriptionController;
  final TextEditingController addressController;

  final List<Company> companies;
  final Future<MessageResponse> Function(UserType) onRegister;
  final Function(MessageResponse)? onRegisterSuccess;
  final Function(dynamic)? onRegisterError;

  final Function(String, String?) onChangeField;

  final bool? isEdit;
  final UserType? role;


  const _RecruiterOrDriverForm({
    required this.emailController,
    required this.descriptionController,
    required this.addressController,
    required this.onChangeField,
    required this.companies,
    required this.onRegister,
    this.onRegisterSuccess,
    this.onRegisterError,
    this.role,
    this.isEdit
  });

  @override
  State<_RecruiterOrDriverForm> createState() => _RecruiterOrDriverFormState();
}

class _RecruiterOrDriverFormState extends State<_RecruiterOrDriverForm> {
  late UserType role;
  TextEditingController get emailController => widget.emailController;
  TextEditingController get descriptionController => widget.descriptionController;
  TextEditingController get addressController => widget.addressController;
  void Function(String, String?) get onChangeField => widget.onChangeField;
  List<Company> get companies => widget.companies;

  Future<MessageResponse> Function(UserType) get onRegister => widget.onRegister;
  void Function(MessageResponse)? get onRegisterSuccess => widget.onRegisterSuccess;
  void Function(dynamic)? get onRegisterError => widget.onRegisterError;

  bool get isEdit => widget.isEdit ?? false;

  @override
  void initState() {
    role = widget.role ?? UserType.driver;
    super.initState();
  }

  void _changeRole(UserType role) {
    Timer(const Duration(milliseconds: 1300), () {
      setState(() {
        this.role = role;
      });
    });
  }

  List<Widget> _fields() {
    if(role == UserType.recruiter) {

      return [
        AppPadding.widget(padding: EdgeInsets.zero),
        form.NamedTextField(
          controller: emailController,
          name: "email",
          onChanged: onChangeField,
          padding: AppPadding.topAndBottom(),
          prefixIcon: form.InputFields.email(),
          validators: [
            FormBuilderValidators.required(),
            FormBuilderValidators.email()
          ],
        ),
        form.NamedTextField(
          controller: descriptionController,
          name: "description",
          onChanged: onChangeField,
          prefixIcon: const Icon(FluentIcons.text_description_32_regular),
          padding: AppPadding.topAndBottom(),
        ),
        if(!isEdit)
        SizedBox(
          width: 200,
          child: AppDropdown(
            items: companies,
            current: companies.firstOrNull,
            name: "companyId",
            label: "Company",
            hint: "Select a company",
            converter: (item) => DropdownMenuItem(value: item, child: Text(item.name),),
            onChange: (item) => onChangeField("companyId", item?.toString()),
            validator: FormBuilderValidators.required(),
          ),
        ),
      ];
    }
    return [
      form.NamedTextField(
        controller: addressController,
        name: "address",
        onChanged: onChangeField,
        prefixIcon: form.InputFields.home(),
        padding: AppPadding.topAndBottom(),
        validators: [
          FormBuilderValidators.required(),
          FormBuilderValidators.match("^[A-z0-9 '\",\\.]*?\$", errorText: "The field has a incorrect char")
        ],
      )
    ];
  }

  List<Widget> _registerActions() => [
    _UserRolButton(role: role, onChange: _changeRole),
    AppPadding.widget(padding: AppPadding.topAndBottom()),
    AppAsyncButton(
      future: () => onRegister(role),
      onSuccess: onRegisterSuccess,
      onError: onRegisterError,
      child: const Text("Sign up"),
    ),
    AppPadding.widget(padding: AppPadding.topAndBottom(value: 6))
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ..._fields(),
      if(!isEdit)
        ..._registerActions(),
    ]);
  }
}

class _UserRolButton extends StatefulWidget {
  final UserType role;
  final Function(UserType)? onChange;
  const _UserRolButton({required this.role, required this.onChange});

  @override
  State<_UserRolButton> createState() => _UserRolButtonState();
}

class _UserRolButtonState extends State<_UserRolButton> {
  late UserType role;
  Function(UserType)? get onChange => widget.onChange;

  @override
  void initState() {
    super.initState();
    role = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
        padding: AppPadding.topAndBottom(),
        child: AnimatedToggleSwitch.dual(
          current: role,
          first: UserType.driver,
          second: UserType.recruiter,
          onChanged: (role) {
            if(onChange != null) {
              onChange!(role);
            }
            setState(() {
              this.role = role;
            });
            return Future.delayed(const Duration(seconds: 1));
          },
          iconBuilder: (role) => role == UserType.driver ? form.InputFields.driver(color: Colors.black) : form.InputFields.person(),
          textBuilder: (role) => Center(child: Text(roleToString(role).toTitleCase()),),
        )
    );
  }
}