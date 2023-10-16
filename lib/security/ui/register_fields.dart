import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zendrivers/recruiters/entities/company.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/security/entities/register.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart' as form;
import 'package:zendrivers/shared/utils/styles.dart';
import 'dart:async';

part 'register_driver_recruiter.dart';

class RegisterFields extends StatelessWidget {
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

  final _maskPhone = MaskTextInputFormatter(mask: "+51 ### ### ###");

  final Account? account;
  final List<Company>? companies;
  final GlobalKey<FormBuilderState>? formKey;

  bool get isEdit => account != null;
  bool get isNotEdit => companies != null;

  RegisterFields({this.account, this.companies, this.formKey, super.key}) :
    assert((account == null && companies != null) || (account != null && companies == null && formKey != null)) {
    if(isEdit) {
      final effectiveAccount = account!;
      _firstnameController.text = effectiveAccount.firstname;
      _lastnameController.text = effectiveAccount.lastname;

      _phoneController.text = _maskPhone.maskText(effectiveAccount.phone);

      if(effectiveAccount.isDriver) {
        _addressDriverController.text = effectiveAccount.driver!.address;
      }
      else if(effectiveAccount.isRecruiter) {
        _emailRecruiterController.text = effectiveAccount.recruiter!.email;
        _descriptionRecruiterController.text = effectiveAccount.recruiter!.description;
      }
    }
  }

  void _validateField(String name, String? value) => (formKey ?? _formKey).currentState?.fields[name]?.validate();

  String? _validatePhone(String? value) {
    if(value != null) {
      if(!value.startsWith("+51 9")){
        return "The phone number must starts with 9";
      }
    }
    return null;
  }

  DriverSave _driverSave() => DriverSave(
    address: _addressDriverController.text,
    birth: DateTime.now()
  );

  RecruiterSave _recruiterSave() => RecruiterSave(
    email: _emailRecruiterController.text,
    description: _descriptionRecruiterController.text,
    companyId: 1
  );

  void _register(BuildContext context, UserType role) {
    if(_formKey.currentState?.validate() ?? false) {
      form.InputFields.unFocus(context);
      final request = SignupRequest(
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        phone: _maskPhone.unmaskText(_phoneController.text),
        role: role,
        driver: role == UserType.driver ? _driverSave() : null,
        recruiter: role == UserType.recruiter ? _recruiterSave() : null,
        username: _usernameController.text,
        password: _passwordController.text
      );
      ZenDrivers.prints(request.toRawJson());

    }
  }

  List<Widget> _passwordFields() => [
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
  ];

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey ?? _formKey,
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
            readOnly: isEdit,
            controller: _phoneController,
            onChanged: _validateField,
            validators: [
              FormBuilderValidators.required(),
              _validatePhone,
              FormBuilderValidators.equalLength(15, errorText: "Phone number must have a length equal to 9")
            ],
            prefixIcon: const Icon(Icons.phone_callback),
            keyboardType: TextInputType.number,
            formatters: [_maskPhone],
          ),
          if(isNotEdit)
            form.UsernameField(
              controller: _usernameController,
              onChanged: _validateField,
              padding: AppPadding.topAndBottom(),
            ),
          if(isNotEdit)
            ..._passwordFields(),
          _RecruiterOrDriverForm(
            formKey: _formKey,
            emailController: _emailRecruiterController,
            descriptionController: _descriptionRecruiterController,
            addressController: _addressDriverController,
            onChangeField: _validateField,
            companies: companies ?? [],
            onRegister: (role) => _register(context, role),
            isEdit: isEdit,
            role: account?.role,
          )
        ],
      ),
    );
  }
}
