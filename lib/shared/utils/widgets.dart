import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:zendrivers/shared/utils/validators.dart';

class ImageUtils {
  static Widget loading(BuildContext context, Widget child, ImageChunkEvent? loading) {
    if(loading == null) {
      return child;
    }
    return Center(
      child: CircularProgressIndicator(
        value: loading.expectedTotalBytes != null ? loading.cumulativeBytesLoaded / loading.expectedTotalBytes!
            : null,
      ),
    );
  }

  static Widget net(String url, {
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loading,
    double? width,
    double? height,
    Widget? defaultWidget,
    BoxFit? fit,
  }) {
    if(url.isValidUrl()) {
      return Image.network(url,
        loadingBuilder: loading,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return defaultWidget ?? Container();
  }

  static Widget avatar({String? url, double radius = 20, Widget? defaultIcon, EdgeInsets? padding}) {
    final effectiveDefaultIcon = defaultIcon ?? Icon(Icons.person, color: Colors.black, size: radius * 1.5,);
    final effectiveNetworkImage = url != null && url.isValidUrl();
    return AppPadding.widget(
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        decoration: BoxDecorations.circle(color: Colors.grey),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: radius,
          backgroundImage: effectiveNetworkImage ? NetworkImage(url) : null,
          child: effectiveNetworkImage ? null : effectiveDefaultIcon,
        ),
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


class AppFutureBuilder<Ty extends Object> extends StatefulWidget {
  final Future<Ty> future;
  final Widget? errorChild;
  final Widget Function(Ty) builder;
  final int maxSeconds;
  final String? timeoutMessage;
  final bool showException;
  const AppFutureBuilder({super.key, required this.future, this.errorChild, required this.builder, this.maxSeconds = 10, this.showException = true, this.timeoutMessage});

  @override
  State<AppFutureBuilder<Ty>> createState() => _AppFutureBuilderState<Ty>();
}

class _AppFutureBuilderState<Ty extends Object> extends State<AppFutureBuilder<Ty>> {
  bool _break = false;

  Future<Ty> get future => widget.future;
  Widget? get errorChild => widget.errorChild;
  Widget Function(Ty) get builder => widget.builder;
  int get maxSeconds => widget.maxSeconds;
  String? get timeoutMessage => widget.timeoutMessage;
  bool get showException => widget.showException;

  void _timeToBreak() {
    Timer(Duration(seconds: maxSeconds), () {
      if(!_break) {
        setState(() {
          _break = true;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          if(!_break) {
            _timeToBreak();
            return const Center(child: CircularProgressIndicator(),);
          }
          if(_break) {
            return AppToast(
              message: timeoutMessage ?? "The request took too long (already of $maxSeconds seconds).",
              child: errorChild,
            );
          }
        }

        _break = true;
        if(snapshot.hasError) {
          return AppToast(
            message: showException ? "${snapshot.error}" : null,
            child: errorChild,

          );
        }

        if(!snapshot.hasData) {
          return AppToast(
            message: "The response doesn't have data",
            child: errorChild,
          );
        }

        return builder(snapshot.data!);
      },
    );
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



class OverflowColumn extends StatefulWidget {
  final int maxItems;
  final Iterable<Widget> items;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  const OverflowColumn({
    super.key,
    required this.maxItems,
    required this.items,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center
  });

  @override
  State<OverflowColumn> createState() => _OverflowColumnState();
}

class _OverflowColumnState extends State<OverflowColumn> {
  late int maxCount;
  int get max => widget.maxItems;
  Iterable<Widget> get items => widget.items;

  @override
  void initState() {
    super.initState();
    maxCount = max;
    _validateCount();
  }

  void _validateCount() {
    if (maxCount > items.length) {
      maxCount = items.length;
    }
  }

  void _showMore() {
    setState(() {
      maxCount += max;
      _validateCount();
    });
  }

  void _showLess() {
    setState(() {
      maxCount -= max;
      if(maxCount < max) {
        maxCount = max;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...items.take(maxCount),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (items.isNotEmpty && maxCount < items.length)
              TextButton(
                onPressed: _showMore,
                child: const Text('View more'),
              ),
            if(items.isNotEmpty && maxCount > max)
              TextButton(
                onPressed: _showLess,
                child: const Text("View less"),
              )
          ],
        )

      ],
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
  const AppTile({
    super.key,
    this.padding,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.boxRadius = 12,
    this.onTap
  });

  Widget _container() => Container(
    decoration: BoxDecorations.box(radius: boxRadius),
    child: ListTile(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      leading: leading,
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


