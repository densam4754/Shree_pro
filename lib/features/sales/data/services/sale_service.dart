import 'dart:convert';
import '../../../../core/services/global_api_service.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/models/sale_model.dart';

/// Sale Service
/// Feature-specific service that uses GlobalApiService
class SaleService {
  final GlobalApiService globalApiService;

  SaleService({required this.globalApiService});

  /// Get all sales
  Future<List<SaleModel>> getAllSales() async {
    try {
      final response = await globalApiService.post(
        ApiEndpoints.sale,
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> salesJson = data['SlResp']?['SlDtl'] ?? [];

      return salesJson
          .map((json) => SaleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException('Failed to get sales: $e');
    }
  }
}

