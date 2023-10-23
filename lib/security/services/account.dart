import 'package:zendrivers/security/entities/account.dart';
import 'package:zendrivers/security/entities/login.dart';
import 'package:zendrivers/security/entities/register.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class AccountService extends HttpService {

  static final _instance = AccountService._internal();
  AccountService._internal() : super(ZenDrivers.joinUrl("users"));
  factory AccountService() => _instance;

  Future<MessageResponse> login(LoginRequest request) async {
    final result = await post(body: request, append: "sign-in", auth: false);
    if(result.isOk) {
      MessageResponse response = MessageResponse(message: "Login Successfully");
      response.valid = true;
      await preferences.saveLogin(LoginResponse.fromRawJson(result.body));
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
  Future<MessageResponse> signup(SignupRequest request) async {
    final response = await post(body: request, append: "sign-up", auth: false);
    return messageResponse(response, "Register successfully");
  }
  Future<MessageResponse> update(int id, AccountUpdateRequest request) async {
    final response = await put(body: request, append: "$id");
    return messageResponse(response, "Updated successfully");
  }

  Future<Account?> getByUsername(String username) async {
    final response = await get(append: "search?username=$username");
    return response.isOk ? Account.fromRawJson(response.body) : null;
  }

  Future<MessageResponse> changePassword(ChangePasswordRequest request) async {
    final response = await post(body: request, append: "change-password");
    return messageResponse(response, "Password changed successfully");
  }

}