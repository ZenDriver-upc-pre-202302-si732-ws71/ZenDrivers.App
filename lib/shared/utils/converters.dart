import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

void andThen<Ty extends Object>(Future<Ty> future, {Function(Ty)? then}) =>
    future.then((value) {
      then != null ? then(value) : {};
    });


extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');

  Iterable<Ty> jsonToIter<Ty extends Object>(Ty Function(Map<String, dynamic>)? converter) {
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
  List<Ty> jsonIterToList<Ty extends Object>(Ty Function(Map<String, dynamic>) converter) => map((e) => converter(e)).toList();

}

extension IterableExtensions<Ty extends Object> on Iterable<Ty> {
  List<Map<String, dynamic>> iterToJsonList(Map<String, dynamic> Function(Ty) converter) => map((e) => converter(e)).toList();
}

extension DateTimeExtension on DateTime {
  String timeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays >= 1) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours >= 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes >= 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }
}

extension ResponseExtension on Response {
  bool get isOk => statusCode == HttpStatus.ok;
  bool get isCreated => statusCode == HttpStatus.created;
}