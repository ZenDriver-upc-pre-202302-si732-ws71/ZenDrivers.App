import 'package:async_button/async_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/shared/utils/navigation.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/validators.dart';
import 'package:zendrivers/shared/utils/widgets.dart';

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

  static Widget profile(String url, {EdgeInsets? padding, double height = 150, double border=8}) {
    return AppPadding.widget(
      padding: padding,
      child: Container(
          height: height,
          decoration: BoxDecorations.box(color: Colors.white),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(border),
            child: ImageUtils.net(url,
                fit: BoxFit.fill
            ),
          )
      ),
    );
  }
}


class AppButton extends StatelessWidget {
  final EdgeInsets? padding;
  final Function()? onClick;
  final Widget? child;
  const AppButton({super.key, this.padding, this.onClick, this.child});

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
        padding: padding ?? AppPadding.leftAndRight(),
        child: ElevatedButton(
          onPressed: onClick,
          child: child,
        )
    );
  }
}

class AppAsyncButton<Ty extends Object?> extends StatelessWidget {
  final EdgeInsets? padding;
  final Future<Ty> Function() future;
  final Widget child;
  final void Function(Ty)? onSuccess;
  final void Function(dynamic)? onError;
  final _controller = AsyncBtnStatesController();
  final double squareDimension;
  AppAsyncButton({super.key, this.padding, required this.future, required this.child, this.onSuccess, this.onError, this.squareDimension = 24});


  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
        padding: padding ?? AppPadding.leftAndRight(),
        child: AsyncElevatedBtn(
          asyncBtnStatesController: _controller,
          onPressed: () async {
            _controller.update(AsyncBtnState.loading);
            try {
              final response = await future();
              _controller.update(AsyncBtnState.success);
              if(onSuccess != null) {
                onSuccess!(response);
              }
            } catch(e) {
              _controller.update(AsyncBtnState.idle);
              if(onError != null) {
                onError!(e);
              }
            }
          },
          loadingStyle: AsyncBtnStateStyle(
            widget: SizedBox.square(
              dimension: squareDimension,
              child: const CircularProgressIndicator(),
            ),
          ),
          child: child,
        )
    );
  }
}

class AppToast extends StatelessWidget {
  final String? message;
  final Widget? child;

  static void show(BuildContext context, String message, {StyledToastPosition? position}) {
    showToast(message,
      context: context,
      position: position ?? StyledToastPosition.center,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      duration: const Duration(seconds: 4),
      animDuration: const Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  const AppToast({super.key,this.message, this.child});

  @override
  Widget build(BuildContext context) {
    if(message != null) {
      afterBuild(callback: () => show(context, message!));
    }
    return Center(child: child);
  }
}

class AppDropdown<Ty> extends StatelessWidget {
  final String name;
  final Iterable<Ty> items;
  final DropdownMenuItem<Ty> Function(Ty) converter;
  final void Function(Ty?)? onChange;
  final Ty? current;
  final String label;
  final String hint;
  final EdgeInsets? padding;
  final String? Function(Ty?)? validator;
  final GlobalKey<FormBuilderFieldDecorationState>? dropdownKey;
  const AppDropdown({
    super.key,
    required this.name,
    required this.items,
    required this.converter,
    this.onChange,
    required this.label,
    required this.hint,
    this.current,
    this.padding,
    this.validator,
    this.dropdownKey
  });

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
      padding: padding ?? EdgeInsets.zero,
      child: FormBuilderDropdown<Ty>(
        key: dropdownKey,
        name: name,
        initialValue: current,
        onChanged: onChange,
        items: items.map((e) => converter(e)).toList(),
        decoration: InputDecoration(
            border: InputFields.border,
            enabledBorder: InputFields.border,
            labelText: label,
            hintText: hint
        ),
        validator: validator,
      ),
    );
  }
}


class AppTile extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final double boxRadius;
  final void Function()? onTap;
  final EdgeInsets? contentPadding;
  const AppTile({
    super.key,
    this.padding,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.boxRadius = 12,
    this.onTap,
    this.contentPadding
  });

  Widget _container() => Container(
    decoration: BoxDecorations.box(radius: boxRadius),
    child: ListTile(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      leading: leading,
      contentPadding: contentPadding,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
        padding: padding ?? AppPadding.horAndVer(vertical: 5),
        child: onTap != null ? InkWell(
          onTap: onTap,
          child: _container(),
        ) : _container()
    );
  }
}