import 'package:shared_preferences/shared_preferences.dart';
import 'package:zendrivers/security/entities/login.dart';

class AppPreferences {
  SharedPreferences? _preferences;
  LoginResponse? _credentials;

  bool get isPresent => _preferences != null;
  bool get hasCredentials => isPresent && _preferences!.containsKey(credentialsKey);

  static String get credentialsKey => "user";

  static final instance = AppPreferences._internal();


  AppPreferences._internal() {
    SharedPreferences.getInstance().then((value) {
      _preferences = value;
    });
  }
  factory AppPreferences() => instance;

  Future<void> saveLogin(LoginResponse response) async {
    if(isPresent) {
      await _preferences!.setString(credentialsKey, response.toRawJson());
      _credentials = response;
    } else {
      throw Exception("Preferences wasn't loaded");
    }
  }

  LoginResponse getCredentials() {
    if(!isPresent) {
      throw Exception("Preferences wasn't loaded");
    }
    if(!hasCredentials){
      throw Exception("User is not logged");
    }
    _credentials ??= LoginResponse.fromRawJson(_preferences!.getString(credentialsKey)!);
    return _credentials!;
  }

  Future<bool> removeCredentials() async {
    if(isPresent){
      return _preferences!.remove(credentialsKey);
    }
    return false;
  }

  void setImageUrl(String? url) {
    if(hasCredentials) {
      _credentials?.imageUrl = url;
    }
  }

  Future<void> load() async => _preferences = await SharedPreferences.getInstance();

}