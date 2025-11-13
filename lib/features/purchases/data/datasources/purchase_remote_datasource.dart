import '../../../../core/errors/exceptions.dart';
import '../services/purchase_service.dart';
import '../../domain/models/purchase_model.dart';

abstract class PurchaseRemoteDataSource {
  Future<List<PurchaseModel>> getAllPurchases();
}

class PurchaseRemoteDataSourceImpl implements PurchaseRemoteDataSource {
  final PurchaseService purchaseService;

  PurchaseRemoteDataSourceImpl({required this.purchaseService});

  @override
  Future<List<PurchaseModel>> getAllPurchases() async {
    try {
      return await purchaseService.getAllPurchases();
    } on ServerException {
      rethrow;
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get purchases: $e');
    }
  }
}

