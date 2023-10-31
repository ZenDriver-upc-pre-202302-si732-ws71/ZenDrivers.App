import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:zendrivers/shared/utils/environment.dart';

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');

  Iterable<Ty> jsonToIter<Ty extends Object?>(Ty Function(Map<String, dynamic>)? converter) {
    try{
      final dict = jsonDecode(this) as Iterable;
      return converter == null ? dict as Iterable<Ty> : dict.map((e) => converter(e));
    } catch(e){
      print(e.toString());
      return const Iterable.empty();
    }
  }

  bool isValidUrl() {
    final uri = Uri.tryParse(this);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }
}

extension IterableDynamicExtensions on Iterable {
  List<Ty> jsonIterToList<Ty extends Object?>(Ty Function(Map<String, dynamic>) converter) => map((e) => converter(e)).toList();

}

extension IterableExtensions<Ty extends Object?> on Iterable<Ty> {
  List<Map<String, dynamic>> iterToJsonList(Map<String, dynamic> Function(Ty) converter) => map((e) => converter(e)).toList();

  Iterable<Ty> operator*(Object other) {
    if(other is int) {
      final effectiveIterable = <Ty>[];
      for(int i = 0; i < other; i++) {
        effectiveIterable.addAll(List.from(this));
      }
      return effectiveIterable;
    }
    return this;
  }
}

extension ListExtensions<Ty extends Object?> on List<Ty> {
  void replaceFor(Ty source, Ty other) {
    try {
      final index = indexOf(source);
      insert(index, other);
      remove(source);
    } catch(_) {}
  }
}

class DateFormatters {
  static DateFormat get hoursTime => DateFormat("hh:mm a");
  static DateFormat get dateTime => DateFormat("MM/dd/y, hh:mm a");
  static DateFormat get date => DateFormat("MM/dd/y");
  static DateFormat get weekdayTime => DateFormat("${DateFormat.WEEKDAY}, hh:mm a");
}

extension DateTimeExtension on DateTime {
  
  bool isSameDay(DateTime date) => day == date.day && month == date.month && year == date.year;
  bool isYesterday(DateTime date) => isSameDay(date.subtract(const Duration(days: 1)));
  bool isWeekAgo(DateTime date) => isAfter(date.subtract(const Duration(days: 7))) && isBefore(date);

  String timeAgo({
    DateFormat? weekFormat,
    DateFormat? weekLaterFormat,
    DateFormat? hoursFormat,
    DateFormat? minutesFormat,
    String? yesterday,
    String? today,
  }) {
    final now = DateTime.now();
    if(isSameDay(now)) {
      final diff = now.difference(this);
      int effectiveTime = diff.inMinutes;
      if(today != null) {
        return today;
      }
      if(effectiveTime < 1) {
        return "Just now";
      }
      else if(effectiveTime < 60) {
        return minutesFormat?.format(this) ?? '$effectiveTime ${effectiveTime == 1 ? 'minute' : 'minutes'} ago';
      }
      effectiveTime = diff.inHours;
      return hoursFormat?.format(this) ?? '$effectiveTime ${effectiveTime == 1 ? 'hour' : 'hours'} ago';
    }
    else if(isYesterday(now)) {
      return yesterday ?? "Yesterday, ${(hoursFormat ?? DateFormatters.hoursTime).format(this)}";
    }

    final week = isWeekAgo(now);

    final effectiveFormatter = week ? (weekFormat ?? DateFormatters.weekdayTime) : (weekLaterFormat ?? DateFormatters.dateTime);
    return effectiveFormatter.format(this);
  }

}


extension ResponseExtension on Response {
  bool get isOk => statusCode == HttpStatus.ok;
  bool get isCreated => statusCode == HttpStatus.created;
}

class MutableObject<Ty extends Object?> {
  Ty value;
  MutableObject(this.value);
  @override
  String toString() => value.toString();
}