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

part 'register_form.dart';

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
        ZenDrivers.prints(key);
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



