import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/security/entities/register.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart' as env;
import 'package:zendrivers/shared/utils/environment.dart';

class AccountService extends HttpService {

  static final _instance = AccountService._internal();
  AccountService._internal() : super(env.joinUrl("users"));
  factory AccountService() => _instance;

  Future<MessageResponse> login(LoginRequest request) async {
    final result = await post(body: request, append: "sign-in", auth: false);
    if(result.isOk) {
      MessageResponse response = MessageResponse(message: "Login Successfully");
      response.valid = true;
      preferences.saveLogin(LoginResponse.fromRawJson(result.body));
      return response;
    }
    try {
      return MessageResponse.fromRawJson(result.body);
    } catch (e) {
      return MessageResponse(message: result.body);
    }

  }
  Future<MessageResponse> validatePreferences() async {
    await loadPreferences();
    final credentials = preferences.getCredentials();
    final request = AuthenticateRequest(username: credentials.username, token: credentials.token);
    return messageResponse(await post(body: request, append: "validate"), "Valid credentials");
  }
  Future<MessageResponse> signup(SignupRequest request) async => messageResponse(await post(body: request, append: "sign-up"), "Register successfully");
  Future<MessageResponse> update(AccountUpdateRequest request) async => messageResponse(await put(body: request), "Updated successfully");
}