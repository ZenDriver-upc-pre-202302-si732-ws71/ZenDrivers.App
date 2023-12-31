import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class BoxDecorations {
  static BoxDecoration box({Color? color, Color? background, double radius = 10}) => BoxDecoration(
    border: Border.all(color: color ?? Colors.lightBlueAccent),
    color: background,
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );

  static BoxDecoration search({Color? color, double radius = 30}) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: color ?? Colors.grey[400]!),
    color: color ?? const Color(0xFFE8E8EE),
  );

  static BoxDecoration circle({Color? color}) => BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: color ?? Colors.lightBlueAccent),
  );
}

class ChatBubbleClip {

  static CustomClipper<Path> sender({bool last = true}) => ChatBubbleClipper9(
    type: BubbleType.sendBubble,
    nipSize: last ? 6 : 4,
    sizeRatio: last ? 3 : 1
  );

  static CustomClipper<Path> receiver({bool last = true}) => ChatBubbleClipper10(
    type: BubbleType.receiverBubble,
    nipSize: last ? 6 : 4,
    sizeRatio: last ? 3 : 1
  );
}


class AppPadding {
  static Widget widget({Widget? child, EdgeInsets? padding}) => Padding(
    padding: padding ?? horAndVer(),
    child: child,
  );

  static Widget zeroWidget() => widget(padding: all(value: 0));

  static EdgeInsets left({double value = 8}) => EdgeInsets.only(left: value);
  static EdgeInsets right({double value = 8}) => EdgeInsets.only(right: value);
  static EdgeInsets top({double value = 8}) => EdgeInsets.only(top: value);
  static EdgeInsets bottom({double value = 8}) => EdgeInsets.only(bottom: value);
  static EdgeInsets leftAndRight({double value = 8}) => EdgeInsets.only(left: value, right: value);
  static EdgeInsets topAndBottom({double value = 8}) => EdgeInsets.only(top: value, bottom: value);
  static EdgeInsets horAndVer({double horizontal = 8, double vertical = 8}) => EdgeInsets.only(left: horizontal, right: horizontal, top: vertical, bottom: vertical);
  static EdgeInsets all({double value = 8}) => EdgeInsets.all(value);

}


class AppText {
  static TextStyle get bold => const TextStyle(fontWeight:  FontWeight.w700);
  static TextStyle get title => const TextStyle(fontWeight: FontWeight.w400, fontSize: 18);
  static TextStyle get comment => const TextStyle(
    fontSize: 10
  );

  static TextStyle get paragraph => const TextStyle(
    fontSize: 13
  );
}

