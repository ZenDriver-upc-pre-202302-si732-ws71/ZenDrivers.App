import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zendrivers/drivers/entities/driver.dart';
import 'package:zendrivers/drivers/entities/experience.dart';
import 'package:zendrivers/drivers/entities/license.dart';
import 'package:zendrivers/drivers/services/driver.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

class ListDriver extends StatelessWidget {

  DriverService get _driverService => DriverService();
  final DriverFindRequest? request;

  const ListDriver({super.key, this.request});

  static void toDriverView(BuildContext context, Driver driver) {
    Navegations.persistentTo(context, Scaffold(
      appBar: ZenDrivers.bar(context,
        leading: ZenDrivers.back(context),
        title: "${driver.account.firstname}'s profile"
      ),
      body: SingleChildScrollView(
        child: _DriverView(driver: driver),
      ),
    ));
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


class _DriverView extends StatelessWidget {
  final Driver driver;
  const _DriverView({required this.driver});

  void _contactDriver() {

  }

  List<Widget> _nothingToShow() => [Text("Nothing to show", style: AppText.paragraph,)];

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
      padding: AppPadding.horAndVer(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Theme.of(context).colorScheme.primary,
            elevation: 1,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AppPadding.widget(
                    padding: AppPadding.horAndVer(horizontal: 6),
                    child: Container(
                      height: 150,
                      decoration: BoxDecorations.box(color: Colors.white),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ImageUtils.net(driver.account.imageUrl ?? ZenDrivers.defaultProfileUrl,
                          fit: BoxFit.cover
                        ),
                      )
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      ShowField(
                        text: AppPadding.widget(
                          padding: AppPadding.horAndVer(vertical: 5),
                          child: Text(driver.account.firstname,
                            style: AppText.paragraph,
                          )
                        ),
                        background: Colors.white,
                        padding: AppPadding.right()
                      ),
                      AppPadding.widget(padding: AppPadding.topAndBottom(value: 5)),
                      ShowField(
                        text: AppPadding.widget(
                          padding: AppPadding.horAndVer(vertical: 5),
                          child: Text(driver.account.lastname,
                          style: AppText.paragraph,
                          )
                        ),
                        background: Colors.white,
                        padding: AppPadding.right(),
                      ),
                      AppPadding.widget(padding: AppPadding.topAndBottom(value: 5)),
                      AppButton(
                        onClick: _contactDriver,
                        child: const Text("Contact"),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          AppPadding.widget(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Text("Work Experiences", style: AppText.title,)
          ),
          OverflowColumn(
            maxItems: 2,
            items: driver.experiences.isNotEmpty ? driver.experiences.map((e) => _DriverExperience(experience: e)) : _nothingToShow(),
          ),
          AppPadding.widget(
            padding: const EdgeInsets.only(top: 8, left: 8),
            child: Text("Licenses", style: AppText.title,)
          ),
          OverflowColumn(
            maxItems: 2,
            items: driver.licenses.isNotEmpty ? driver.licenses.map((e) => _DriverLicense(license: e)) : _nothingToShow(),
          )
        ],
      ),
    );
  }
}


class _DriverExperience extends StatelessWidget {
  final DriverExperience experience;
  final DateFormat? format;
  DateFormat get _dateFormat => format ?? DateFormat('dd/MM/yyyy');
  const _DriverExperience({required this.experience, this.format});

  @override
  Widget build(BuildContext context) {
    return AppTile(
      title: Text(experience.description),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Text("From: ${_dateFormat.format(experience.startDate)}"),
          ),
          Expanded(
            child: Text("To: ${_dateFormat.format(experience.endDate)}"),
          )
        ],
      ),
    );
  }
}

class _DriverLicense extends StatelessWidget {
  final License license;
  final DateFormat? format;
  DateFormat get _dateFormat => format ?? DateFormat('dd/MM/yyyy');
  const _DriverLicense({required this.license, this.format});

  @override
  Widget build(BuildContext context) {
    return AppTile(
      title: Text("Category: ${license.category.name}"),
      subtitle: Row(
        children: <Widget>[
          Expanded(
            child: Text("From: ${_dateFormat.format(license.start)}"),
          ),
          Expanded(
            child: Text("To: ${_dateFormat.format(license.end)}"),
          )
        ],
      ),
    );
  }
}


