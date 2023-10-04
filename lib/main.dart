import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:zendrivers/recruiters/ui/home.dart';
import 'package:zendrivers/recruiters/ui/search.dart';
import 'package:zendrivers/security/ui/login.dart';
import 'package:zendrivers/security/ui/profile.dart';
import 'package:zendrivers/shared/utils/styles.dart';

void main() => runApp(const ZenDriversApp());

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
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  ZenDriversPage({super.key});

  List<Widget> _screens() => [
    const Home(),
    const Search(),
    const Profile()
  ];

  List<PersistentBottomNavBarItem> _barItems(BuildContext context) => [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home),
      inactiveIcon: const Icon(Icons.home_outlined),
      activeColorPrimary: Theme.of(context).colorScheme.primary,
      inactiveColorPrimary: Theme.of(context).colorScheme.secondary,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.search),
      inactiveIcon: const Icon(Icons.search_outlined),
      activeColorPrimary: Theme.of(context).colorScheme.primary,
      inactiveColorPrimary: Theme.of(context).colorScheme.secondary,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.person),
      inactiveIcon: const Icon(Icons.person_outline_outlined),
      activeColorPrimary: Theme.of(context).colorScheme.primary,
      inactiveColorPrimary: Theme.of(context).colorScheme.secondary,
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

