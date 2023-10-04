import 'package:zendrivers/recruiters/entities/company.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/environment.dart' as env;

class CompanyService extends HttpService {
  static final _instance = CompanyService._internal();
  CompanyService._internal() : super(env.joinUrl("companies"));
  factory CompanyService() => _instance;

  Future<List<Company>> getAll() async => await iterableGet(auth: false, converter: Company.fromJson);

}