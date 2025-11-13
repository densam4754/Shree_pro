import '../../../../core/errors/exceptions.dart';
import '../services/supplier_service.dart';
import '../../domain/models/supplier_model.dart';

abstract class SupplierRemoteDataSource {
  Future<List<SupplierModel>> getAllSuppliers();
}

class SupplierRemoteDataSourceImpl implements SupplierRemoteDataSource {
  final SupplierService supplierService;

  SupplierRemoteDataSourceImpl({required this.supplierService});

  @override
  Future<List<SupplierModel>> getAllSuppliers() async {
    try {
      return await supplierService.getAllSuppliers();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get suppliers: $e');
    }
  }
}

