import '../../../../core/utils/typedefs.dart';
import '../entities/sale_entity.dart';

abstract class SaleRepository {
  ResultFuture<List<SaleEntity>> getAllSales();
}

