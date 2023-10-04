import 'package:flutter/material.dart';
import 'package:zendrivers/drivers/entities/driver.dart';
import 'package:zendrivers/drivers/services/driver.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class ListDriver extends StatelessWidget {

  DriverService get _driverService => DriverService();
  final DriverFindRequest? request;

  const ListDriver({super.key, this.request});

  void _toDriverView(BuildContext context, Driver driver) {
    Navegations.persistentTo(context, Scaffold(
      appBar: ZenDrivers.bar(context, leading: ZenDrivers.back(context)),
      body: SingleChildScrollView(
        child: _DriverView(driver: driver),
      ),
    ));
  }

  Widget _driver(BuildContext context, Driver driver) => AppPadding.widget(
    padding: AppPadding.horAndVer(vertical: 5),
    child: InkWell(
      onTap: () => _toDriverView(context, driver),
      child: Container(
        decoration: AppDecorations.box(radius: 12),
        child: ListTile(
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
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
      future: request != null ? _driverService.find(request!) : _driverService.getAll(),
      builder: (data) {
        final drivers = List.filled(10, data[0]);
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


class _DriverView extends StatelessWidget {
  final Driver driver;
  const _DriverView({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
