import 'package:flutter/material.dart';
import 'package:zendrivers/shared/utils/navigation.dart';

class ZenDrivers {
  static PreferredSizeWidget bar(BuildContext context, {Widget? leading, String? title, Widget? widTitle, List<Widget>? actions}) => AppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    title: widTitle ?? Text(title ?? "ZenDrivers", style: const TextStyle(color: Colors.white),
    ),
    titleSpacing: 1,
    leading: leading ?? ZenDrivers.logo(),
    actions: actions,
  );

  static Widget logo({double? scale, double? width, double? height}) => Image.asset("assets/icon.png",
    scale: scale,
    width: width,
    height: height,
  );

  static Widget sliverBar(BuildContext context, {
    bool? logoLeading,
    String? title,
    Widget? widTitle,
  }) => SliverAppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    leading: logoLeading ?? true ? ZenDrivers.logo() : ZenDrivers.back(context),
    title: widTitle ?? Text(title ?? "ZenDrivers", style: const TextStyle(color: Colors.white),),
    titleSpacing: 1,
    floating: true,
    snap: true,
  );

  static Widget sliverScroll({
    required Widget body,
    bool? logoLeading,
    String? title,
    Widget? widTitle
  }) => NestedScrollView(
    headerSliverBuilder: (context, box) => [
      ZenDrivers.sliverBar(context,
        logoLeading: logoLeading,
        title: title,
        widTitle: widTitle
      )
    ],
    body: body,
  );

  static Widget back(BuildContext context, {void Function()? onPressed, Color color = Colors.white}) => IconButton(
    onPressed: onPressed ?? () =>  Navegations.back(context),
    icon: Icon(Icons.arrow_back, color: color),
  );

  static const String defaultProfileUrl = "https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg";

  //const String apiUrl = "http://localhost:5048/api/v1";
  static const String apiUrl = "http://10.0.2.2:5048/api/v1";

  static String joinUrl(String argument) => joinsUrl([argument]);

  static String joinsUrl(List<String> arguments) => "$apiUrl/${arguments.join("/")}";

  static void prints<Ty extends Object?>(Ty message, {String debugName = "Zendrivers"}) => print("$debugName: $message");
}

