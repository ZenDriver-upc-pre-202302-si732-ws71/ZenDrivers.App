import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zendrivers/communication/ui/inbox.dart';
import 'package:zendrivers/shared/ui/home.dart';
import 'package:zendrivers/recruiters/ui/search.dart';
import 'package:zendrivers/security/ui/login.dart';
import 'package:zendrivers/security/ui/account_profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const ZenDriversApp());
}

class ZenDriversApp extends StatelessWidget {
  const ZenDriversApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZenDriver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          backgroundColor: Colors.white,
          accentColor: Colors.lightBlueAccent,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            side: MaterialStateProperty.resolveWith<BorderSide>((_) => const BorderSide(color: Colors.lightBlueAccent)),
            shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
              return RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
            }),
          ),
        )
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ZenDriversPage extends StatelessWidget {
  final int? initialIndex;
  late final PersistentTabController _controller;
  ZenDriversPage({super.key, this.initialIndex}) {
    _controller = PersistentTabController(initialIndex: initialIndex ?? 0);
  }

  List<Widget> _screens() => [
    Home(),
    Search(),
    Inbox(),
    AccountProfile()
  ];

  PersistentBottomNavBarItem _barItem(BuildContext context, {required Widget icon, Widget? inactiveIcon, String? title}) => PersistentBottomNavBarItem(
    icon: icon,
    inactiveIcon: inactiveIcon,
    activeColorPrimary: Theme.of(context).colorScheme.primary,
    inactiveColorPrimary: Theme.of(context).colorScheme.primary,
  );

  List<PersistentBottomNavBarItem> _barItems(BuildContext context) => [
    _barItem(context,
      icon: const Icon(FluentIcons.home_28_filled),
      inactiveIcon: const Icon(FluentIcons.home_28_regular),
      title: "Home"
    ),
    _barItem(context,
      icon: const Icon(FluentIcons.search_28_filled),
      inactiveIcon: const Icon(FluentIcons.search_28_regular),
      title: "Search"
    ),
    _barItem(context,
      icon: const Icon(FluentIcons.mail_inbox_28_filled),
      inactiveIcon: const Icon(FluentIcons.mail_inbox_28_regular),
      title: "Messages"
    ),
    _barItem(context,
      icon: const Icon(FluentIcons.person_28_filled),
      inactiveIcon: const Icon(FluentIcons.person_28_regular),
      title: "Profile"
    )
  ];

  @override
  Widget build(BuildContext context) => PersistentTabView(context,
    controller: _controller,
    screens: _screens(),
    items: _barItems(context),
    hideNavigationBarWhenKeyboardShows: true,
    decoration: NavBarDecoration(
      borderRadius: BorderRadius.circular(10.0),
      colorBehindNavBar: Theme.of(context).colorScheme.background,
    ),
    itemAnimationProperties: const ItemAnimationProperties(
      duration: Duration(milliseconds: 200),
      curve: Curves.ease
    ),
    navBarStyle: NavBarStyle.style14,
  );
}

