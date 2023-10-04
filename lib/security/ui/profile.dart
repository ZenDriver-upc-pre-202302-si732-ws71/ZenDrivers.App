import 'package:flutter/material.dart';
import 'package:zendrivers/security/ui/login.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/preferences.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  void _logout(BuildContext context) {
    AppPreferences preferences = AppPreferences();
    preferences.removeCredentials(then: (removed) {
      Navegations.persistentTo(context, LoginPage(), withNavBar: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context),
      body: Center(
        child: AppButton(
          onClick: () => _logout(context),
          child: const Text("Logout"),
        ),
      ),
    );
  }
}
