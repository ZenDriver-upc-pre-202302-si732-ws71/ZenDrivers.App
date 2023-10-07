import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:zendrivers/main.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/security/services/account.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/security/ui/register.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/validators.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class LoginPage extends StatelessWidget {
  final AccountService _accountService = AccountService();
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ZenDrivers.logo(scale: 1.4),
          AppFutureBuilder(
            future: _accountService.validatePreferences(),
            timeoutMessage: "Time out request",
            builder: (data) {
              appPrint(data.valid.toString());
              if(data.valid) {
                afterBuild(callback: () => Navegations.replace(context, ZenDriversPage()));
                return Container();
              }
              return _LoginForm();
            },
            errorChild: _LoginForm(),
            showException: false,
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();
  final AccountService _accountService = AccountService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  _LoginForm();

  void _signIn(BuildContext context) async {
    if(_formKey.currentState?.validate() ?? false) {
      InputFields.unFocus(context);
      final request = LoginRequest(username: _usernameController.text.trim(), password: _passwordController.text.trim());
      appPrint(request.toRawJson());
      andThen(_accountService.login(request), then: (response) {
        if(!response.valid) {
          AppToast.show(context,response.message);
        }
        Navegations.replace(context, ZenDriversPage());
      });

    }
  }

  void _toRegister(BuildContext context) {
    InputFields.unFocus(context);
    Navegations.to(context, RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
      padding: AppPadding.leftAndRight(value: 30),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          children: [
            UsernameField(
              controller: _usernameController,
              onChanged: (name, value) => _formKey.currentState?.fields[name]?.validate(),
              padding: AppPadding.topAndBottom(),
            ),
            PasswordField(
              controller: _passwordController,
              onChanged: (name, value) => _formKey.currentState?.fields[name]?.validate(),
              padding: AppPadding.topAndBottom(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AppButton(onClick: () => _toRegister(context), child: const Text("Sign Up")),
                AppButton(onClick: () => _signIn(context), child: const Text("Sign in"))
              ],
            )
          ],
        ),
      ),
    );
  }
}



