import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

void andThen<Ty extends Object?>(Future<Ty> future, {Function(Ty)? then}) =>
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
    final difference = DateTime.now().difference(this);
    if (difference.inDays >= 2) {
      return DateFormat("dd/mm/yyyy, hh:mm a").format(this).toLowerCase();
    } else if (difference.inDays >= 1) {
      return 'Yesterday, ${DateFormat("hh:mm a").format(this).toLowerCase()}';
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

class MutableObject<Ty extends Object?> {
  Ty value;
  MutableObject(this.value);
  @override
  String toString() => value.toString();
}