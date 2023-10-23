import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zendrivers/recruiters/entities/company.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/security/entities/register.dart';
import 'package:zendrivers/security/services/account.dart';
import 'package:zendrivers/security/ui/login.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart' as form;
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'dart:async';

import 'package:zendrivers/shared/utils/validators.dart';

part 'register_driver_recruiter.dart';

class RegisterFields extends StatelessWidget {
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final _emailRecruiterController = TextEditingController();
  final _descriptionRecruiterController = TextEditingController();

  final _addressDriverController = TextEditingController();

  final _maskPhone = MaskTextInputFormatter(mask: "+51 ### ### ###");

  final Account? account;
  final List<Company>? companies;

  final AccountService _accountService = AccountService();

  bool get isEdit => account != null;
  bool get isNotEdit => companies != null;

  late final GlobalKey<FormBuilderState> _formKey;

  RegisterFields({this.account, this.companies, GlobalKey<FormBuilderState>? formKey, super.key}) :
    assert((account == null && companies != null) || (account != null && companies == null && formKey != null)) {
    _formKey = formKey ?? GlobalKey();
    if(isEdit) {
      final effectiveAccount = account!;
      _firstnameController.text = effectiveAccount.firstname;
      _lastnameController.text = effectiveAccount.lastname;

      _phoneController.text = _maskPhone.maskText(effectiveAccount.phone);
      _imageUrlController.text = effectiveAccount.imageUrl ?? "";

      if(effectiveAccount.isDriver) {
        _addressDriverController.text = effectiveAccount.driver!.address;
      }
      else if(effectiveAccount.isRecruiter) {
        _emailRecruiterController.text = effectiveAccount.recruiter!.email;
        _descriptionRecruiterController.text = effectiveAccount.recruiter!.description;
      }
    }
  }

  void _validateField(String name, String? value, {bool focusOnError=true}) => _formKey.currentState?.fields[name]?.validate(focusOnInvalid: focusOnError);
  void _invalidateField(String name, String errorText) => _formKey.currentState?.fields[name]?.invalidate(errorText, shouldFocus: false);

  String? _validatePhone(String? value) {
    if(value != null) {
      if(!value.startsWith("+51 9")){
        return "The phone number must starts with 9";
      }
    }
    return null;
  }


  Future<MessageResponse> _register(BuildContext context, UserType role) async {
    if(_formKey.currentState?.validate() ?? false) {
      form.InputFields.unFocus(context);
      final fields = _formKey.currentState?.fields.map((key, value) => MapEntry(key, value.value));
      if(fields != null) {
        fields.putIfAbsent("role", () => roleToString(role));
        fields.putIfAbsent("birth", () => DateTime(1990).toIso8601String());
        fields["phone"] = _maskPhone.unmaskText(fields["phone"]);
        fields["driver"] = role == UserType.driver ? DriverSave.fromJson(fields).toJson() : null;
        fields["recruiter"] = role == UserType.recruiter ? RecruiterSave.fromJson(fields).toJson() : null;

        if((fields["imageUrl"] as String).isEmpty) {
          fields["imageUrl"] = null;
        }
        final request = SignupRequest.fromJson(fields);
        return _accountService.signup(request);
      }
    }
    return MessageResponse(message: "Fill all required fields");
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
        hint: "Confirm your password",
        label: "Confirm password",
        padding: AppPadding.topAndBottom()
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: <Widget>[
          form.TextOnlyField(
            name: "firstname",
            controller: _firstnameController,
            onChanged: _validateField,
            validators: [
              FormBuilderValidators.required(),
            ],
          ),
          form.TextOnlyField(
            name: "lastname",
            controller: _lastnameController,
            onChanged: _validateField,
            validators: [
              FormBuilderValidators.required()
            ],
          ),
          if(isNotEdit)
          form.NamedTextField(
            name: "phone",
            readOnly: isEdit,
            controller: _phoneController,
            onChanged: _validateField,
            validators: [
              FormBuilderValidators.required(),
              _validatePhone,
              FormBuilderValidators.equalLength(15, errorText: "Phone number must have a length equal to 9")
            ],
            prefixIcon: form.InputFields.phone(),
            keyboardType: TextInputType.number,
            formatters: [_maskPhone],
          ),
          if(isNotEdit)
            form.UsernameField(
              controller: _usernameController,
              onChanged: _validateField,
              padding: AppPadding.topAndBottom(),
            ),
          form.ImageUrlField(
            controller: _imageUrlController,
            name: "imageUrl",
            label: "Profile image",
            hint: "Url for profile image",
            onChange: _validateField,
            onUrlError: (name, url) {
              afterBuild(callback: () => _invalidateField(name, "Invalid image url"));
            },
          ),
          if(isNotEdit)
            ..._passwordFields(),
          _RecruiterOrDriverForm(
            emailController: _emailRecruiterController,
            descriptionController: _descriptionRecruiterController,
            addressController: _addressDriverController,
            onChangeField: _validateField,
            companies: companies ?? [],
            onRegister: (role) => _register(context, role),
            onRegisterSuccess: (response) {
              AppToast.show(context, response.message);
              if(response.valid) {
                Navegations.persistentReplace(context, widget: LoginPage());
              }
            },
            isEdit: isEdit,
            role: account?.role,
          )
        ],
      ),
    );
  }
}
