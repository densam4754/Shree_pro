import 'dart:convert';
import '../../../../core/services/global_api_service.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/models/purchase_model.dart';

/// Purchase Service
/// Feature-specific service that uses GlobalApiService
class PurchaseService {
  final GlobalApiService globalApiService;

  PurchaseService({required this.globalApiService});

  /// Get all purchases
  Future<List<PurchaseModel>> getAllPurchases() async {
    try {
      final response = await globalApiService.post(
        ApiEndpoints.purchase,
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> purchasesJson = data['PurcResp']?['PurcDtl'] ?? [];

      return purchasesJson
          .map((json) => PurchaseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException('Failed to get purchases: $e');
    }
  }
}

