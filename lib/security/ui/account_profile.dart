import 'package:flutter/material.dart';
import 'package:zendrivers/drivers/entities/driver.dart';
import 'package:zendrivers/recruiters/entities/recruiter.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/security/services/account.dart';
import 'package:zendrivers/security/ui/login.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/preferences.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class AccountProfile extends StatelessWidget {
  final _accountService = AccountService();
  AppPreferences get _preferences => _accountService.preferences;
  LoginResponse get _credentials => _accountService.preferences.getCredentials();
  AccountProfile({super.key});

  Widget _logoutButton(BuildContext context) => AppAsyncButton(
    future: () => _preferences.removeCredentials(),
    child: const Text("Logout"),
    onSuccess: (value) {
      if(value) {
        Navegations.persistentReplace(context, widget: LoginPage());
      }
    },
  );
  
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
          child: ShowField(
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

  Widget _buildProfile(BuildContext context, Account account) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      AppPadding.widget(
        padding: AppPadding.bottom(),
        child: ImageUtils.avatar(url: account.imageUrl, radius: 80)
      ),
      _showField("Firstname", account.firstname),
      _showField("Lastname", account.lastname),
      _showField("Phone", account.phone),
      _showField("Role", roleToString(account.role).toCapitalized()),
      if(account.isDriver)
        ..._driverFields(account.driver!),
      if(account.isRecruiter)
        ..._recruiterProfile(account.recruiter!),
      AppPadding.widget(padding: AppPadding.top()),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _logoutButton(context)
        ],
      )
    ],
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
          return value != null ? _buildProfile(context, value) : Center(
            child: _logoutButton(context),
          );
        },
      ),
    );
  }
}
