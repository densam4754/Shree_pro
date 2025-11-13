import '../../../../core/errors/exceptions.dart';
import '../services/taxpayer_service.dart';
import '../../domain/models/taxpayer_model.dart';

abstract class TaxpayerRemoteDataSource {
  Future<List<TaxpayerModel>> getAllTaxpayers();
}

class TaxpayerRemoteDataSourceImpl implements TaxpayerRemoteDataSource {
  final TaxpayerService taxpayerService;

  TaxpayerRemoteDataSourceImpl({required this.taxpayerService});

  @override
  Future<List<TaxpayerModel>> getAllTaxpayers() async {
    try {
      return await taxpayerService.getAllTaxpayers();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get taxpayers: $e');
    }
  }
}

