import 'package:zendrivers/communication/entities/conversation.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class ConversationService extends HttpService {
  static final ConversationService _instance = ConversationService._internal();
  ConversationService._internal() : super(ZenDrivers.joinUrl("conversations"));
  factory ConversationService() => _instance;

  Future<List<Conversation>> getAllByUsername(String username) async => await iterableGet(converter: Conversation.fromJson, append: "user/$username");
  Future<Conversation?> getByUsernames(ConversationRequest request) async {
    final uri = Uri(queryParameters: request.toJson());
    var result = await get(append: "user?${uri.query}");
    return result.isOk ? Conversation.fromRawJson(result.body) : null;
  }
}