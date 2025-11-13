import 'dart:convert';
import '../../../../core/services/global_api_service.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/models/supplier_model.dart';

/// Supplier Service
/// Feature-specific service that uses GlobalApiService
class SupplierService {
  final GlobalApiService globalApiService;

  SupplierService({required this.globalApiService});

  /// Get all suppliers
  Future<List<SupplierModel>> getAllSuppliers() async {
    try {
      final response = await globalApiService.post(
        ApiEndpoints.supplier,
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> supplierJson = data['SupplResp']?['SupplDtl'] ?? [];

      return supplierJson
          .map((json) => SupplierModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException('Failed to get suppliers: $e');
    }
  }
}

