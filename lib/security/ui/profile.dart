import 'package:flutter/material.dart';
import 'package:zendrivers/security/ui/login.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/preferences.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class Profile extends StatelessWidget {
  final AppPreferences preferences = AppPreferences();
  Profile({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context),
      body: Center(
        child: AppAsyncButton(
          future: () => preferences.removeCredentials(),
          child: const Text("Logout"),
          onSuccess: (value) {
            if(value) {
              Navegations.persistentReplace(context, widget: LoginPage());
            }
          },
        ),
      ),
    );
  }
}
