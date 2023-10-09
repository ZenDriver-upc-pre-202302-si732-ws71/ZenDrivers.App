part of 'register.dart';

class _RecruiterOrDriverForm extends StatefulWidget {

  final TextEditingController emailController;
  final TextEditingController descriptionController;
  final TextEditingController addressController;

  final List<Company> companies;
  final void Function(UserType) onRegister;

  final Function(String, String?) onChangeField;

  final GlobalKey<FormBuilderState> formKey;

  const _RecruiterOrDriverForm({
    required this.formKey,
    required this.emailController,
    required this.descriptionController,
    required this.addressController,
    required this.onChangeField,
    required this.companies,
    required this.onRegister
  });

  @override
  State<_RecruiterOrDriverForm> createState() => _RecruiterOrDriverFormState();
}

class _RecruiterOrDriverFormState extends State<_RecruiterOrDriverForm> {
  UserType role = UserType.driver;
  TextEditingController get emailController => widget.emailController;
  TextEditingController get descriptionController => widget.descriptionController;
  TextEditingController get addressController => widget.addressController;
  void Function(String, String?) get onChangeField => widget.onChangeField;
  List<Company> get companies => widget.companies;
  GlobalKey<FormBuilderState> get formKey => widget.formKey;

  void Function(UserType) get onRegister => widget.onRegister;

  void _changeRole(UserType role) {
    Timer(const Duration(milliseconds: 1300), () {
      setState(() {
        this.role = role;
      });
    });
  }

  List<Widget> _fields() {
    if(role == UserType.recruiter) {
      emailController.value = TextEditingValue.empty;
      descriptionController.value = TextEditingValue.empty;
      return [
        AppPadding.widget(padding: EdgeInsets.zero),
        form.TextField(
          controller: emailController,
          name: "email",
          onChanged: onChangeField,
          padding: AppPadding.topAndBottom(),
          prefixIcon: const Icon(Icons.email),
          validators: [
            FormBuilderValidators.required(),
            FormBuilderValidators.email()
          ],
        ),
        form.TextField(
          controller: descriptionController,
          name: "description",
          onChanged: onChangeField,
          prefixIcon: const Icon(Icons.description),
          padding: AppPadding.topAndBottom(),
        ),
        SizedBox(
          width: 200,
          child: AppDropdown(
            items: companies,
            name: "companies",
            label: "Company",
            hint: "Select a company",
            converter: (item) => DropdownMenuItem(value: item, child: Text(item.name),),
          ),
        ),
      ];
    }
    return [
      form.TextField(
        controller: addressController,
        name: "address",
        onChanged: onChangeField,
        prefixIcon: const Icon(Icons.home_outlined),
        padding: AppPadding.topAndBottom(),
      )
    ];
  }



  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ..._fields(),
      _UserRolButton(role: role, onChange: _changeRole),
      AppPadding.widget(padding: AppPadding.topAndBottom()),
      AppButton(
        onClick: () => onRegister(role),
        child: const Text("Sign up"),
      ),
      AppPadding.widget(padding: AppPadding.topAndBottom(value: 6))
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
          iconBuilder: (role) => Icon(role == UserType.driver ? Icons.drive_eta_rounded : Icons.person),
          textBuilder: (role) => Center(child: Text(roleToString(role).toTitleCase()),),
        )
    );
  }
}