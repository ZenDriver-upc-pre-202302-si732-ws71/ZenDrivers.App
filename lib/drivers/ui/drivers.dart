import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zendrivers/communication/entities/conversation.dart';
import 'package:zendrivers/communication/services/conversation.dart';
import 'package:zendrivers/communication/ui/inbox.dart';
import 'package:zendrivers/drivers/entities/driver.dart';
import 'package:zendrivers/drivers/entities/experience.dart';
import 'package:zendrivers/drivers/entities/license.dart';
import 'package:zendrivers/drivers/services/driver.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

part 'driver_profile.dart';

class ListDrivers extends StatelessWidget {

  DriverService get _driverService => DriverService();
  final DriverFindRequest? request;

  const ListDrivers({super.key, this.request});

  static void toDriverView(BuildContext context, Driver driver, {bool showContact = true}) {
    Navegations.persistentTo(context, widget: DriverProfile(driver: driver, showContact: showContact,));
  }

  Widget _driver(BuildContext context, Driver driver) => AppTile(
    onTap: () => toDriverView(context, driver),
    title: Row(
      children: <Widget>[
        ImageUtils.avatar(url: driver.account.imageUrl, radius: 18),
        AppPadding.widget(
            padding: AppPadding.left(),
            child: Text("${driver.account.firstname} ${driver.account.lastname}",
              style: AppText.title,
            )
        )
      ],
    ),
    subtitle: Row(
      children: <Widget>[
        Expanded(
          child: Text("Licenses: ${driver.licenses.length}"),
        ),
        Expanded(
          child: Text("Driver experiences: ${driver.experiences.length}"),
        )
      ],
    ),
  );


  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
      future: request != null ? _driverService.find(request!) : _driverService.getAll(),
      builder: (drivers) {
        return SingleChildScrollView(
          child: Column(
            children: [
              ...drivers.map((driver) => _driver(context, driver)),
              AppPadding.widget()
            ],
          ),
        );
      },
    );
  }
}


