import 'dart:convert';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/services/global_api_service.dart';
import '../models/device_model.dart';

class DeviceService {
  final GlobalApiService globalApiService;

  DeviceService({required this.globalApiService});

  Future<List<DeviceModel>> getDevicesBySpRef(String spRefNum) async {
    try {
      final response =
          await globalApiService.post(ApiEndpoints.deviceBySpRef(spRefNum));
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> devicesJson = data['DevResp']?['DevDtl'] ?? [];

      return devicesJson
          .map((json) => DeviceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch devices: $e');
    }
  }
}

