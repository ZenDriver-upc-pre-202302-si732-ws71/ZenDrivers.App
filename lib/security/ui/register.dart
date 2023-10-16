import 'package:flutter/material.dart';
import 'package:zendrivers/recruiters/services/company.dart';
import 'package:zendrivers/security/ui/register_fields.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';


class RegisterPage extends StatelessWidget {
  final _companyService = CompanyService();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: RichFutureBuilder(
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
                child: RegisterFields(companies: data,)
              )
            ],
          ),
        ),
      ),
    );
  }
}



