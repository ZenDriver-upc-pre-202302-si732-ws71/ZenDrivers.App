import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:zendrivers/drivers/entities/driver.dart';
import 'package:zendrivers/recruiters/entities/recruiter.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/security/services/account.dart';
import 'package:zendrivers/security/ui/login.dart';
import 'package:zendrivers/security/ui/register_fields.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart' as fields;
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/preferences.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

part 'account_password.dart';

class AccountProfile extends StatelessWidget {
  final _accountService = AccountService();
  AppPreferences get _preferences => _accountService.preferences;
  LoginResponse get _credentials => _accountService.preferences.getCredentials();
  AccountProfile({super.key});

  Widget _logoutButton(BuildContext context) => AppButton(
    onClick: () => ZenDrivers.showDialog(
      context: context,
      dialog: _LogoutDialog(preferences: _preferences),
      transitionDuration: const Duration(milliseconds: 300)
    ),
    child: const Text("Logout"),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context),
      body: RichFutureBuilder(
        showException: false,
        timeoutMessage: "Time out",
        future: _accountService.getByUsername(_credentials.username),
        builder: (value) {
          return value != null ? _ProfileFields(
            account: value,
            logoutButton: _logoutButton(context),
          ) : Center(
            child: _logoutButton(context),
          );
        },
      ),
    );
  }
}


class _ProfileFields extends StatefulWidget {
  final Account account;
  final Widget logoutButton;
  const _ProfileFields({required this.account, required this.logoutButton});

  @override
  State<_ProfileFields> createState() => _ProfileFieldsState();
}

class _ProfileFieldsState extends State<_ProfileFields> {

  late Account account;
  final _formKey = GlobalKey<FormBuilderState>();
  Widget get logoutButton => widget.logoutButton;
  bool edit = false;

  @override
  void initState() {
    super.initState();
    account = widget.account;
  }

  Widget _showField(String name, String value) => AppPadding.widget(
    padding: AppPadding.top(),
    child: Row(
      children: <Widget>[
        Expanded(
          child: AppPadding.widget(
            padding: AppPadding.leftAndRight(value: 5),
            child: Container(
              padding: AppPadding.horAndVer(horizontal: 4),
              decoration: BoxDecorations.box(),
              child: Text(name, textAlign: TextAlign.center,),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: fields.ShowField(
            text: Text(value),
            padding: AppPadding.right(value: 5),
            background: Colors.grey[350],
            containerPadding: AppPadding.horAndVer(),
            decoration: BoxDecorations.box(
                background: const Color(0xFFE8E8EE),
                color: Colors.grey[400]
            ),
          ),
        )
      ],
    ),
  );

  List<Widget> _driverFields(DriverResource driver) => [
    _showField("Address", driver.address),
    _showField("Birth", DateFormatters.date.format(driver.birth))
  ];

  List<Widget> _recruiterProfile(RecruiterResource recruiter) => [
    _showField("Email", recruiter.email),
    _showField("Description", recruiter.description),
    _showField("Company", recruiter.company.name)
  ];

  Widget _showAccountFields() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _showField("Firstname", account.firstname),
      _showField("Lastname", account.lastname),
      _showField("Phone", account.phone),
      _showField("Role", roleToString(account.role).toCapitalized()),
      if(account.isDriver)
        ..._driverFields(account.driver!),
      if(account.isRecruiter)
        ..._recruiterProfile(account.recruiter!),
    ]
  );

  Widget _editFields() => AppPadding.widget(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RegisterFields(
          account: account,
          formKey: _formKey,
        ),
        TextButton(
          onPressed: () =>  ZenDrivers.showDialog(
            context: context,
            dialog: _ChangePasswordDialog()
          ),
          child: const Text("Change password"),
        )
      ],
    )
  );

  Widget _cancelOrEdit() => AppButton(
    child: edit ? const Text("Cancel") : const Text("Edi profile"),
    onClick: () {
      setState(() {
        edit = !edit;
      });
    },
  );

  Widget _save() => AppAsyncButton(
    future: () async {
      final fields = _formKey.currentState!.fields.map((key, value) => MapEntry(key, value.value));
      ZenDrivers.prints(AccountUpdateRequest.fromJson(fields).toRawJson());
      ZenDrivers.prints(fields);
    },
    onError: (value) => ZenDrivers.prints("On Error callback"),
    child: const Text("Save"),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AppPadding.widget(
              padding: AppPadding.bottom(),
              child: ImageUtils.avatar(url: account.imageUrl, radius: 80)
            ),
            Container(
              child: edit ? _editFields() : _showAccountFields(),
            ),
            AppPadding.widget(padding: AppPadding.top()),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: edit ? _cancelOrEdit() : logoutButton,
                ),
                Container(
                  child: edit ? _save() : _cancelOrEdit(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _LogoutDialog extends StatelessWidget {
  final AppPreferences preferences;

  const _LogoutDialog({required this.preferences});

  Widget _logoutButton(BuildContext context) => AppAsyncButton(
    future: () => preferences.removeCredentials(),
    onSuccess: (value) {
      if(value) {
        Navegations.persistentReplace(context, widget: LoginPage());
      }
    },
    onError: (value) => AppToast.show(context, value.toString()),
    child: const Text("Logout"),
  );
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Logout",
        style: AppText.title,
      ),
      actions: [
        AppButton(
          onClick: () => Navegations.back(context),
          child: const Text("Cancel"),
        ),
        _logoutButton(context)
      ],
      content: Text("Are you sure you want to logout?",
        style: AppText.paragraph,
      ),
    );
  }
}
