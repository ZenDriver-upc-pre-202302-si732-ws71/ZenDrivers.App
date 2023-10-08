import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/preferences.dart';


class HttpService {
  final String _serviceUrl;
  final preferences = AppPreferences();

  HttpService(this._serviceUrl);

  Map<String, String> _getHeaders(bool auth, bool accepts) {
    final headers = <String, String> {};
    headers[HttpHeaders.contentTypeHeader] = "application/json";
    if(auth) {
      final token = preferences.getCredentials().token;
      headers[HttpHeaders.authorizationHeader] = "Bearer $token";
    }
    if(accepts) {
      headers[HttpHeaders.acceptHeader] = "application/json";
    }
    return headers;
  }
  Future<void> loadPreferences() async {
    if(!preferences.isPresent) {
      await preferences.load();
    }
  }

  Future<http.Response> get({String? append, bool? auth}) async {
    await loadPreferences();
    return await http.get(joinToUri(append ?? ""), headers: _getHeaders(auth ?? true, false));
  }

  Future<http.Response> post({String? append, bool? auth, required Object body}) async {
    await loadPreferences();
    return await http.post(joinToUri(append ?? ""),
        headers: _getHeaders(auth ?? true, true),
        body: jsonEncode(body));
  }

  Future<http.Response> put({String? append, required Object body}) async {
    await loadPreferences();
    return await http.put(joinToUri(append ?? ""),
        headers: _getHeaders(true, true),
        body: jsonEncode(body));
  }

  Future<http.Response> delete({required String append}) async {
    await loadPreferences();
    return await http.delete(joinToUri(append),
        headers: _getHeaders(true, true));
  }

  MessageResponse messageResponse(http.Response response, String successMessage) {
    if(response.isOk) {
      final result = MessageResponse(message: successMessage);
      result.valid = true;
      return result;
    }
    try {
      return MessageResponse.fromRawJson(response.body);
    } catch(e) {
      return MessageResponse(message: response.body);
    }
  }

  String joinToUrl(String append) => "$_serviceUrl/$append";
  Uri joinToUri(String append) => Uri.parse(joinToUrl(append));

  Future<List<Ty>> iterableGet<Ty extends Object>(
      {String? append, bool? auth, required Ty Function(Map<String, dynamic>) converter}) async {
    final response = await get(append: append, auth: auth);
    return response.isOk ? response.body.jsonToIter(converter).toList() : List.empty();
  }

}