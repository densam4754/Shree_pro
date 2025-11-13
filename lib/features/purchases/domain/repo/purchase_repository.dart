import '../../../../core/utils/typedefs.dart';
import '../entities/purchase_entity.dart';

abstract class PurchaseRepository {
  ResultFuture<List<PurchaseEntity>> getAllPurchases();
}

