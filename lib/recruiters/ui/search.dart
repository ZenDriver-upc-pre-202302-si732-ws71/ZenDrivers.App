import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:marquee_text/marquee_text.dart';
import 'package:zendrivers/drivers/entities/driver.dart';
import 'package:zendrivers/drivers/entities/license.dart';
import 'package:zendrivers/drivers/services/license.dart';
import 'package:zendrivers/drivers/ui/drivers.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class Search extends StatelessWidget {
  final LicenseCategoryService _licenseCategoryService = LicenseCategoryService();
  LoginResponse get credentials => _licenseCategoryService.preferences.getCredentials();
  final _licenseKey = GlobalKey<FormBuilderFieldDecorationState>();
  final _experienceKey = GlobalKey<FormBuilderFieldDecorationState>();
  Search({super.key});

  void _listDrivers(BuildContext context, {required String title, DriverFindRequest? request}) {
    Navegations.persistentTo(context,
      widget: Scaffold(
        body: ZenDrivers.sliverScroll(
            logoLeading: false,
            title: title,
            widTitle: MarqueeText(
              speed: 20,
              text: TextSpan(text: title),
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.white),
            ),
            body: ListDriver(request: request,)
        ),
      )
    );
  }

  void _filterDrivers(BuildContext context) {
    _licenseKey.currentState?.validate();
    if(_licenseKey.currentState?.isValid ?? false) {
      final licenseName = (_licenseKey.currentState?.value as LicenseCategory).name;
      final experienceValue = _experienceKey.currentState?.value.toString();
      DriverFindRequest request = DriverFindRequest(yearsOfExperience: 0, categoryName: licenseName);
      String effectiveTitle = "Drivers with license type $licenseName";

      if(experienceValue != null && experienceValue.isNotEmpty) {
        effectiveTitle += " & $experienceValue years of experience";
        request.yearsOfExperience = int.tryParse(experienceValue.replaceAll("+", "")) ?? 0;
      }

      _listDrivers(context, title: effectiveTitle, request: request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ZenDrivers.bar(context),
      body: AppFutureBuilder(
        future: _licenseCategoryService.getAll(),
        builder: (categories) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(credentials.isDriver ? "Get to know drivers like you" : "Find your ideal driver",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500
                ),
                textAlign: TextAlign.center,
              ),
              AppPadding.widget(
                padding: AppPadding.horAndVer(vertical: 10, horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: AppDropdown(
                        dropdownKey: _licenseKey,
                        items: categories,
                        onChange: (value) => _licenseKey.currentState?.validate(),
                        padding: AppPadding.leftAndRight(),
                        name: "categories",
                        label: "Licence Type",
                        hint: "Select a type",
                        validator: FormBuilderValidators.required(errorText: "Select a type"),
                        converter: (item) => DropdownMenuItem(value: item, child: Text(item.name)),
                      ),
                    ),
                    Expanded(
                      child: AppDropdown(
                        dropdownKey: _experienceKey,
                        items: const ["0+", "1+", "3+", "5+", "10+"],
                        padding: AppPadding.leftAndRight(),
                        name: "experience",
                        label: "Experience",
                        hint: "Experience",
                        current: "0+",
                        converter: (item) => DropdownMenuItem(value: item, child: Text("$item years"),),
                      ),
                    )
                  ],
                ),
              ),
              AppButton(
                onClick: () => _filterDrivers(context),
                child: const Text("Filter"),
              ),
              AppButton(
                onClick: () => _listDrivers(context, title: "All Drivers"),
                child: const Text("View all drivers"),
              )
            ],
          );
        },
      ),
    );
  }
}
