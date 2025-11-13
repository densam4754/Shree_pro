import 'dart:convert';
import '../../../../core/services/global_api_service.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/models/insurance_model.dart';

/// Insurance Service
/// Feature-specific service that uses GlobalApiService
class InsuranceService {
  final GlobalApiService globalApiService;

  InsuranceService({required this.globalApiService});

  /// Get all insurance
  Future<List<InsuranceModel>> getAllInsurance() async {
    try {
      final response = await globalApiService.post(
        ApiEndpoints.insurance,
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> insuranceJson = data['InsResp']?['InsDtl'] ?? [];

      return insuranceJson
          .map((json) => InsuranceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException('Failed to get insurance: $e');
    }
  }
}

