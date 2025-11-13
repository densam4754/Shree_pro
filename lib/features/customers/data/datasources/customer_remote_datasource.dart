import '../../../../core/errors/exceptions.dart';
import '../services/customer_service.dart';
import '../../domain/models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getAllCustomers();
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final CustomerService customerService;

  CustomerRemoteDataSourceImpl({required this.customerService});

  @override
  Future<List<CustomerModel>> getAllCustomers() async {
    try {
      return await customerService.getAllCustomers();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get customers: $e');
    }
  }
}

