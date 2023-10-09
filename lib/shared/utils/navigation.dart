import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';


class Navegations {
  static Future<Ty?> to<Ty>(BuildContext context, Widget objective) => Navigator.of(context).push(MaterialPageRoute(builder: (context) => objective));
  static void back<Ty>(BuildContext context, [Ty? result]) => Navigator.pop(context, result);
  static void replace(BuildContext context, Widget widget) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget));
  static void persistentTo(BuildContext context, {required Widget widget, bool? withNavBar}) => PersistentNavBarNavigator.pushNewScreen(context,
    screen: widget,
    pageTransitionAnimation: PageTransitionAnimation.scale,
    withNavBar: withNavBar
  );

  static void persistentReplace(BuildContext context, {required Widget widget}) => Navigator.of(context, rootNavigator: true)
      .pushReplacement(MaterialPageRoute(builder: (context) => widget));
}