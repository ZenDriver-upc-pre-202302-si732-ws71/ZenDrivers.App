import 'dart:async';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zendrivers/recruiters/entities/company.dart';
import 'package:zendrivers/recruiters/services/company.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';
import 'package:zendrivers/shared/utils/fields.dart' as form;

class RegisterPage extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _emailRecruiterController = TextEditingController();
  final _descriptionRecruiterController = TextEditingController();

  final _addressDriverController = TextEditingController();

  final _companyService = CompanyService();

  void _validateField(String name, String? value) => _formKey.currentState?.fields[name]?.validate();

  String? _validatePhone(String? value) {
    if(value != null) {
      if(!value.startsWith("+51 9")){
        return "The phone number must starts with 9";
      }
    }
    return null;
  }

  void _register(BuildContext context, UserType role) {
    if(_formKey.currentState?.validate() ?? false) {
      form.InputFields.unFocus(context);
      _formKey.currentState?.fields.forEach((key, value) {
        ZenDrivers.print(key);
      });
    }

  }

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: AppFutureBuilder(
        future: _companyService.getAll(),
        errorChild: AppButton(
          child: const Text("To login"),
          onClick: () => Navegations.back(context),
        ),
        builder: (data) => SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ZenDrivers.logo(scale: 1.5),
              AppPadding.widget(
                padding: AppPadding.leftAndRight(value: 20),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      form.TextField(
                        name: "firstname",
                        controller: _firstnameController,
                        onChanged: _validateField,
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.match(r"^[A-z ]*$", errorText: "Firstname must contains only letter and spaces")
                        ],
                        padding: AppPadding.topAndBottom(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      form.TextField(
                        name: "lastname",
                        controller: _lastnameController,
                        onChanged: _validateField,
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.match(r"^[A-z ]*$", errorText: "Lastname must contains only letter and spaces")
                        ],
                        padding: AppPadding.topAndBottom(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      form.TextField(
                        name: "phone",
                        controller: _phoneController,
                        onChanged: _validateField,
                        validators: [
                          FormBuilderValidators.required(),
                          _validatePhone,
                          FormBuilderValidators.equalLength(15, errorText: "Phone number must have a length equal to 9")
                        ],
                        prefixIcon: const Icon(Icons.phone_callback),
                        keyboardType: TextInputType.number,
                        formatters: [MaskTextInputFormatter(mask: "+51 ### ### ###")],
                      ),
                      form.UsernameField(
                        controller: _usernameController,
                        onChanged: _validateField,
                        padding: AppPadding.topAndBottom(),
                      ),
                      form.PasswordField(
                        controller: _passwordController,
                        onChanged: _validateField,
                        padding: AppPadding.topAndBottom(),
                      ),
                      form.PasswordField(
                        controller: _confirmController,
                        onChanged: (name, _) {
                          final field = _formKey.currentState?.fields[name];
                          if(field?.validate() ?? false) {
                            if(_confirmController.text != _passwordController.text) {
                              field?.invalidate("The field value must be equal to password field");
                            }
                          }
                        },
                        name: "confirmPassword",
                        hint: "Confirm password",
                        padding: AppPadding.topAndBottom()
                      ),
                      _RecruiterOrDriverForm(
                        formKey: _formKey,
                        emailController: _emailRecruiterController,
                        descriptionController: _descriptionRecruiterController,
                        addressController: _addressDriverController,
                        onChangeField: _validateField,
                        companies: data,
                        onRegister: (role) => _register(context, role),
                      )
                    ],
                  ),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}

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
