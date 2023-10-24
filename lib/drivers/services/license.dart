import 'package:zendrivers/drivers/entities/license.dart';
import 'package:zendrivers/shared/entities/response.dart';
import 'package:zendrivers/shared/services/http_service.dart';
import 'package:zendrivers/shared/utils/converters.dart';
import 'package:zendrivers/shared/utils/environment.dart';

class LicenseService extends HttpService {
  static final _instance = LicenseService._internal();
  LicenseService._internal() : super(ZenDrivers.joinUrl("licenses"));
  factory LicenseService() => _instance;

  Future<EntityResponse<License>> create(LicenseRequest request) async {
    final response = await post(body: request);
    return response.isCreated ? EntityResponse(License.fromRawJson(response.body), message: "Create successfully") : EntityResponse.invalid(message: response.body);
  }

  Future<MessageResponse> deleteLicense(int id) async {
    final response = await delete(append: "$id");
    return messageResponse(response, "Delete successfully");
  }
}

class LicenseCategoryService extends HttpService {
  static final _instance = LicenseCategoryService._internal();
  LicenseCategoryService._internal() : super(ZenDrivers.joinUrl("licensecategories"));
  factory LicenseCategoryService() => _instance;
  Future<List<LicenseCategory>> getAll() => iterableGet(converter: LicenseCategory.fromJson);


}