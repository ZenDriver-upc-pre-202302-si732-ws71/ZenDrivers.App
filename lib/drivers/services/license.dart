import 'package:zendrivers/drivers/entities/license.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/environment.dart' as env;

class LicenseService extends HttpService {
  static final _instance = LicenseService._internal();
  LicenseService._internal() : super(env.joinUrl("licenses"));
  factory LicenseService() => _instance;
}

class LicenseCategoryService extends HttpService {
  static final _instance = LicenseCategoryService._internal();
  LicenseCategoryService._internal() : super(env.joinUrl("licensecategories"));
  factory LicenseCategoryService() => _instance;
  Future<List<LicenseCategory>> getAll() => iterableGet(converter: LicenseCategory.fromJson);
}