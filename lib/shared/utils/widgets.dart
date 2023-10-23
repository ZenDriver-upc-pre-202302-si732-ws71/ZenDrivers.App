import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/fields.dart';
import 'package:zendrivers/shared/utils/styles.dart';
import 'package:http/http.dart' as http;

class ImageUtils {
  static Widget loading(BuildContext context, Widget child, ImageChunkEvent? loading) {
    if(loading == null) {
      return child;
    }
    return Center(
      child: CircularProgressIndicator(
        color: Colors.black,
        value: loading.expectedTotalBytes != null ? loading.cumulativeBytesLoaded / loading.expectedTotalBytes!
            : null,
      ),
    );
  }

  static Widget net(String url, {
    Widget Function(BuildContext, Widget, ImageChunkEvent?)? loading,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
    double? width,
    double? height,
    Widget? defaultWidget,
    BoxFit? fit,
  }) {
    if(url.isValidUrl()) {
      return Image.network(url,
        loadingBuilder: loading,
        errorBuilder: errorBuilder,
        width: width,
        height: height,
        fit: fit,
      );
    }
    return defaultWidget ?? Container();
  }

  static Widget avatar({String? url, double radius = 20, Widget? defaultIcon, EdgeInsets? padding, void Function(String)? onError, Widget Function(String?, double, Widget)? avatarBuilder}) {
    final effectiveDefaultIcon = defaultIcon ?? InputFields.person(color: Colors.black, size: radius * 1.5,);
    final isValidUrl = url != null;
    ZenDrivers.prints(isValidUrl);
    return AppPadding.widget(
      padding: padding ?? EdgeInsets.zero,
      child: Container(
        decoration: BoxDecorations.circle(color: Colors.grey),
        child: avatarBuilder != null ? avatarBuilder(url, radius, effectiveDefaultIcon) : CircleAvatarManage(
          radius: radius,
          foregroundImage: isValidUrl ? NetworkImage(url) : null,
          onForegroundError: () {
            if(onError != null && isValidUrl) {
              onError(url);
            }
            return effectiveDefaultIcon;
          },
          child: effectiveDefaultIcon,
        ),
      ),
    );
  }
}

class CircleAvatarManage extends StatefulWidget {
  final Widget? child;
  final Color? backgroundColor;
  final ImageProvider<Object>? backgroundImage;
  final ImageProvider<Object>? foregroundImage;
  final Widget Function()? onBackgroundError;
  final Widget Function()? onForegroundError;
  final double? radius;
  const CircleAvatarManage({
    super.key,
    this.child,
    this.backgroundColor,
    this.backgroundImage,
    this.foregroundImage,
    this.radius,
    this.onBackgroundError,
    this.onForegroundError
  });

  @override
  State<CircleAvatarManage> createState() => _CircleAvatarManageState();
}

class _CircleAvatarManageState extends State<CircleAvatarManage> {
  bool _bgError = false;
  bool _fgError = false;

  bool get hasBackground => widget.backgroundImage != null;
  bool get hasForeground => widget.foregroundImage != null;

  bool get hasError => _fgError || _bgError;

  Widget? _errorChild() {
    if(_bgError && widget.onBackgroundError != null) {
      return widget.onBackgroundError!();
    }
    if(_fgError && widget.onForegroundError != null) {
      return widget.onForegroundError!();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ZenDrivers.prints(hasError, debugName: "Circle");
    return CircleAvatar(
      radius: widget.radius,
      foregroundImage: widget.foregroundImage,
      backgroundImage: widget.backgroundImage,
      backgroundColor: widget.backgroundColor ?? Colors.transparent,
      onBackgroundImageError: hasBackground ? (context, stack) {
        setState(() {
          _bgError = true;
          _fgError = false;
        });
      } : null,
      onForegroundImageError: hasForeground ? (context, stack) {
        setState(() {
          _bgError = false;
          _fgError = true;
        });
      } : null,
      child: (hasError ? _errorChild() : null) ?? widget.child,
    );
  }
}



class RichFutureBuilder<Ty extends Object?> extends StatefulWidget {
  final Future<Ty> future;
  final Widget Function()? errorChild;
  final Widget Function(Ty) builder;
  final int maxSeconds;
  final String? timeoutMessage;
  final bool showException;
  final EdgeInsets? loadingPadding;

  const RichFutureBuilder({
    super.key,
    required this.future,
    this.errorChild,
    required this.builder,
    this.maxSeconds = 10,
    this.showException = true,
    this.timeoutMessage,
    this.loadingPadding
  });

  @override
  State<RichFutureBuilder<Ty>> createState() => _RichFutureBuilderState<Ty>();
}

class _RichFutureBuilderState<Ty extends Object?> extends State<RichFutureBuilder<Ty>> {
  bool _break = false;
  bool _showed = false;

  Future<Ty> get future => widget.future;
  Widget? get errorChild => widget.errorChild != null ? widget.errorChild!() : null;
  Widget Function(Ty) get builder => widget.builder;
  int get maxSeconds => widget.maxSeconds;
  String? get timeoutMessage => widget.timeoutMessage;
  bool get showException => widget.showException;
  EdgeInsets get loadingPadding => widget.loadingPadding ?? EdgeInsets.zero;


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
            return Center(
              child: AppPadding.widget(
                padding: loadingPadding,
                child: const CircularProgressIndicator(),
              ),
            );
          }
          if(_break) {
            return AppToast(
              message: showException ? timeoutMessage ?? "The request took too long (already of $maxSeconds seconds)." : null,
              child: !_showed ? errorChild : null,
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
        final body = builder(snapshot.data as Ty);
        _showed = true;
        return body;
      },
    );
  }
}

class NetworkImageManage extends StatelessWidget {
  final String url;
  final Widget Function(Uint8List) onSuccess;
  final Widget Function()? onError;
  final Widget? onDefault;
  const NetworkImageManage({
    super.key,
    required this.url,
    required this.onSuccess,
    this.onError,
    this.onDefault
  });

  bool get hasOnError => onError != null;

  @override
  Widget build(BuildContext context) {
    return RichFutureBuilder(
      future: http.get(Uri.parse(url)),
      loadingPadding: AppPadding.all(value: 10),
      builder: (response) {
        if(response.isOk){
          return onSuccess(response.bodyBytes);
        }
        else if(hasOnError) {
          return onError!();
        }
        return onDefault ?? const SizedBox();
      },
      errorChild: hasOnError ? () => onError!() : null,
      showException: false,
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
  State<OverflowColumn> createState() => OverflowColumnState();
}

class OverflowColumnState extends State<OverflowColumn> {
  late int maxCount;
  int get max => widget.maxItems;
  Iterable<Widget> get items => widget.items;

  void update({required int length}) {
    setState(() {
      maxCount = length;
      _validateCount();
    });
  }

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



