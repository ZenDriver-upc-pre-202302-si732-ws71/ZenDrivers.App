import 'package:zendrivers/recruiters/entities/recruiter.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class RecruiterService extends HttpService {
  static final RecruiterService _instance = RecruiterService._internal();
  RecruiterService._internal() : super(ZenDrivers.joinUrl("recruiters"));
  factory RecruiterService() => _instance;

  Future<List<Recruiter>> getByCompanyId(int companyId) async => await iterableGet(converter: Recruiter.fromJson, append: "company/$companyId");

}