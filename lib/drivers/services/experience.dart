import 'package:zendrivers/drivers/entities/experience.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class DriverExperienceService extends HttpService {
  static final _instance = DriverExperienceService._internal();
  DriverExperienceService._internal() : super(ZenDrivers.joinUrl("driverexperiences"));
  factory DriverExperienceService() => _instance;

  Future<EntityResponse<DriverExperience>> save(DriverExperienceRequest request) async {
    final response = await post(body: request);
    return response.isCreated ? EntityResponse(DriverExperience.fromRawJson(response.body), message: "Created successfully") : EntityResponse.invalid(message: response.body);
  }

  Future<MessageResponse> deleteExperience(int id) async {
    final response = await delete(append: "$id");
    return messageResponse(response, "Delete successfully");
  }

}