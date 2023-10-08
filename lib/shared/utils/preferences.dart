import 'package:shared_preferences/shared_preferences.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/shared/utils/converters.dart';

class AppPreferences {
  SharedPreferences? _preferences;
  LoginResponse? _credentials;

  bool get isPresent => _preferences != null;
  bool get hasCredentials => isPresent && _preferences!.containsKey("user");

  static String get credentialsKey => "user";

  static final instance = AppPreferences._internal();


  AppPreferences._internal() {
    andThen(SharedPreferences.getInstance(), then: (value) {
      _preferences = value;
    });
  }
  factory AppPreferences() => instance;

  void saveLogin(LoginResponse response) {
    if(isPresent) {
      andThen(_preferences!.setString(credentialsKey, response.toRawJson()));
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

  void removeCredentials({void Function(bool)? then}) {
    if(isPresent){
      _preferences!.remove(credentialsKey).then(then ?? (value) {});
    }
  }


  Future<void> load() async => _preferences = await SharedPreferences.getInstance();

}