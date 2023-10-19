import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';
import 'package:zendrivers/shared/utils/styles.dart';

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


class RichFutureBuilder<Ty extends Object?> extends StatefulWidget {
  final Future<Ty> future;
  final Widget? errorChild;
  final Widget Function(Ty) builder;
  final int maxSeconds;
  final String? timeoutMessage;
  final bool showException;
  const RichFutureBuilder({super.key, required this.future, this.errorChild, required this.builder, this.maxSeconds = 10, this.showException = true, this.timeoutMessage});

  @override
  State<RichFutureBuilder<Ty>> createState() => _RichFutureBuilderState<Ty>();
}

class _RichFutureBuilderState<Ty extends Object?> extends State<RichFutureBuilder<Ty>> {
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
              message: showException ? timeoutMessage ?? "The request took too long (already of $maxSeconds seconds)." : null,
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

        return builder(snapshot.data as Ty);
      },
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



