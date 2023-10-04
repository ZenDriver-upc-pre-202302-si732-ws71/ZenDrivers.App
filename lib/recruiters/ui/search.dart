import 'package:flutter/material.dart';
import 'package:zendrivers/drivers/services/license.dart';
import 'package:zendrivers/drivers/ui/drivers.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class Search extends StatelessWidget {
  LicenseCategoryService get _licenseCategoryService => LicenseCategoryService();
  LoginResponse get credentials => _licenseCategoryService.preferences.getCredentials();
  const Search({super.key});

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
                        items: categories,
                        padding: AppPadding.leftAndRight(),
                        name: "categories",
                        label: "Licence Type",
                        hint: "Select a type",
                        converter: (item) => DropdownMenuItem(value: item, child: Text(item.name)),
                      ),
                    ),
                    Expanded(
                      child: AppDropdown(
                        items: const ["1+", "3+", "5+", "10+"],
                        padding: AppPadding.leftAndRight(),
                        name: "experience",
                        label: "Experience",
                        hint: "Experience",
                        converter: (item) => DropdownMenuItem(value: item, child: Text("$item years"),),
                      ),
                    )
                  ],
                ),
              ),
              AppButton(
                onClick: () {

                },
                child: const Text("Filter"),
              ),
              AppButton(
                onClick: () {
                  Navegations.persistentTo(context, Scaffold(
                    body: ZenDrivers.sliverScroll(
                      logoLeading: false,
                      title: "All Drivers",
                      body: const ListDriver()
                    ),
                  ));
                },
                child: const Text("View all drivers"),
              )
            ],
          );
        },
      ),
    );
  }
}
