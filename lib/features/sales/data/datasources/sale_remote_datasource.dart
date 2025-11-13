import '../../../../core/errors/exceptions.dart';
import '../services/sale_service.dart';
import '../../domain/models/sale_model.dart';

abstract class SaleRemoteDataSource {
  Future<List<SaleModel>> getAllSales();
}

class SaleRemoteDataSourceImpl implements SaleRemoteDataSource {
  final SaleService saleService;

  SaleRemoteDataSourceImpl({required this.saleService});

  @override
  Future<List<SaleModel>> getAllSales() async {
    try {
      return await saleService.getAllSales();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get sales: $e');
    }
  }
}

