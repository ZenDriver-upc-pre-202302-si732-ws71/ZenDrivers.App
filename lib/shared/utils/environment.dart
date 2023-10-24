import 'package:async_button_builder/async_button_builder.dart';
import 'package:date_field/date_field.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
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
    icon: Icon(FluentIcons.arrow_left_48_regular, color: color),
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

  static Future<void> showDialog({required BuildContext context, required Widget dialog, Duration? transitionDuration}) => showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    context: context,
    pageBuilder: (context, first, second) => Container(),
    transitionBuilder: (context, first, second, child) => Transform.scale(
      scale: Curves.easeInOut.transform(first.value),
      child: dialog,
    ),
    transitionDuration: transitionDuration ?? const Duration(milliseconds: 300)
  );
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
  final double squareDimension;
  const AppAsyncButton({super.key, this.padding, required this.future, required this.child, this.onSuccess, this.onError, this.squareDimension = 24});

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
        padding: padding ?? AppPadding.leftAndRight(),
        child: AsyncButtonBuilder(
          onPressed: () async {
            try {
              final response = await future();
              if(onSuccess != null) {
                onSuccess!(response);
              }
            } catch(e) {
              if(onError != null) {
                onError!(e);
              }
            }
          },
          builder: (context, child, callback, state) {
            return AppButton(
              onClick: callback,
              child: child,
            );
          },
          successWidget: AppPadding.zeroWidget(),
          successDuration: Duration.zero,
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
  final Widget? icon;
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
    this.icon,
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
        icon: icon,
        decoration: InputDecoration(
          border: InputFields.border,
          enabledBorder: InputFields.border,
          labelText: label,
          hintText: hint,
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

class AppDatePicker extends StatelessWidget {
  final String label;
  final Widget? prefixIcon;
  final EdgeInsets? padding;
  final List<FormFieldValidator<DateTime?>>? validators;
  final void Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePicker({super.key, required this.label, this.prefixIcon, required this.onDateSelected, this.padding, this.validators, this.firstDate, this.lastDate});

  @override
  Widget build(BuildContext context) {
    return AppPadding.widget(
      padding: padding ?? EdgeInsets.zero,
      child: DateTimeFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          border: InputFields.border,
          enabledBorder: InputFields.border,
          prefixIcon: prefixIcon ?? const Icon(FluentIcons.calendar_48_regular),
          labelText: label,
        ),
        firstDate: firstDate,
        lastDate: lastDate,
        mode: DateTimeFieldPickerMode.date,
        onDateSelected: onDateSelected,
        validator: validators != null ? FormBuilderValidators.compose(validators!) : null,
      ),
    );
  }
}
