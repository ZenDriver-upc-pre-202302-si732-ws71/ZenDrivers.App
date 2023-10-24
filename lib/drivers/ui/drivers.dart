import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:zendrivers/communication/entities/conversation.dart';
import 'package:zendrivers/communication/services/conversation.dart';
import 'package:zendrivers/communication/ui/inbox.dart';
import 'package:zendrivers/drivers/entities/driver.dart';
import 'package:zendrivers/drivers/entities/experience.dart';
import 'package:zendrivers/drivers/entities/license.dart';
import 'package:zendrivers/drivers/services/driver.dart';
import 'package:zendrivers/drivers/services/experience.dart';
import 'package:zendrivers/drivers/services/license.dart';
import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

part 'driver_profile.dart';

class ListDrivers extends StatelessWidget {

  DriverService get _driverService => DriverService();
  final DriverFindRequest? request;
  final _informationKey = GlobalKey<_DriverInformationState>();

  ListDrivers({super.key, this.request});

  static void toDriverView(BuildContext context, Driver driver, {bool showContact = true, bool withBar = true, void Function()? onInformationChange}) {
    Navegations.persistentTo(context, widget: DriverProfile(driver: driver, showContact: showContact, onInformationChange: onInformationChange,), withNavBar: withBar);
  }

  Widget _driver(BuildContext context, Driver driver) => AppTile(
    onTap: () => toDriverView(context, driver,
      onInformationChange: () => _informationKey.currentState?.update()
    ),
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
    subtitle: _DriverInformation(key: _informationKey, driver: driver),
  );


  @override
  Widget build(BuildContext context) {
    return RichFutureBuilder(
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

class _DriverInformation extends StatefulWidget {
  final Driver driver;

  const _DriverInformation({super.key, required this.driver});

  @override
  State<_DriverInformation> createState() => _DriverInformationState();
}

class _DriverInformationState extends State<_DriverInformation> {

  void update() {
    setState(() {

    });
  }

  Driver get driver => widget.driver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text("Licenses: ${driver.licenses.length}"),
        ),
        Expanded(
          child: Text("Driver experiences: ${driver.experiences.length}"),
        )
      ],
    );
  }
}

