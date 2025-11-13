import 'dart:convert';
import '../../../../core/services/global_api_service.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/models/taxpayer_model.dart';

/// Taxpayer Service
/// Feature-specific service that uses GlobalApiService
class TaxpayerService {
  final GlobalApiService globalApiService;

  TaxpayerService({required this.globalApiService});

  /// Get all taxpayers
  Future<List<TaxpayerModel>> getAllTaxpayers() async {
    try {
      final response = await globalApiService.post(
        ApiEndpoints.taxpayer,
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> taxpayersJson = data['SpResp']?['SpDtl'] ?? [];

      return taxpayersJson
          .map((json) => TaxpayerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException('Failed to get taxpayers: $e');
    }
  }
}

