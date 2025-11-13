import 'dart:convert';
import '../../../../core/services/global_api_service.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/models/customer_model.dart';

/// Customer Service
/// Feature-specific service that uses GlobalApiService
class CustomerService {
  final GlobalApiService globalApiService;

  CustomerService({required this.globalApiService});

  /// Get all customers
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      final response = await globalApiService.post(
        ApiEndpoints.customer,
      );

      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> customersJson = data['CustomResp']?['CustomDtl'] ?? [];
      
      return customersJson
          .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ServerException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } on NetworkException catch (e) {
      throw NetworkException(e.message);
    } catch (e) {
      throw NetworkException('Failed to get customers: $e');
    }
  }
}

