import 'package:zendrivers/communication/entities/message.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class MessageService extends HttpService {
  MessageService() : super(ZenDrivers.joinUrl("messages"));

  Future<Message?> send(MessageRequest request) async {
    final response = await post(body: request);
    return response.isCreated ? Message.fromRawJson(response.body) : null;
  }

}