import 'package:zendrivers/drivers/entities/driver.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class DriverService extends HttpService {
  static final _instance = DriverService._internal();
  DriverService._internal() : super(ZenDrivers.joinUrl("drivers"));
  factory DriverService() => _instance;

  Future<List<Driver>> getAll() async => await iterableGet(converter: Driver.fromJson);

  Future<List<Driver>> find(DriverFindRequest request) async {
    final result = await post(body: request, append: "find");
    return result.isOk ? result.body.jsonToIter(Driver.fromJson).toList() : List.empty();
  }

  Future<Driver?> findByUsername(String username) async {
    final response = await get(append: "user/$username");
    return response.isOk ? Driver.fromRawJson(response.body) : null;
  }
}