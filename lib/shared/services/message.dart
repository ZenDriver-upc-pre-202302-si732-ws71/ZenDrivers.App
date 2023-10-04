import 'package:zendrivers/shared/entities/message.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart' as env;
import 'package:zendrivers/shared/utils/environment.dart';

class MessageService extends HttpService {
  MessageService() : super(env.joinUrl("messages"));

  Future<MessageResponse> send(MessageRequest request) async => messageResponse(await post(body: request), "Message send successfully");
  Future<List<Message>> getConversation(ConversationRequest request) async {
    final result = await post(body: request);
    return result.isOk ? result.body.jsonToIter(Message.fromJson).toList() : List.empty();
  }

}