import 'package:zendrivers/recruiters/entities/recruiter.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class RecruiterService extends HttpService {
  static final RecruiterService _instance = RecruiterService._internal();
  RecruiterService._internal() : super(ZenDrivers.joinUrl("recruiters"));
  factory RecruiterService() => _instance;

  Future<List<Recruiter>> getByCompanyId(int companyId) async => await iterableGet(converter: Recruiter.fromJson, append: "company/$companyId");
  Future<Recruiter?> getByUsername(String username) async {
    final response = await get(append: "user/$username");
    return response.isOk ? Recruiter.fromRawJson(response.body) : null;
  }
}