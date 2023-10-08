import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class DriverExperienceService extends HttpService {
  static final _instance = DriverExperienceService._internal();
  DriverExperienceService._internal() : super(ZenDrivers.joinUrl("driverexperiences"));
  factory DriverExperienceService() => _instance;

}