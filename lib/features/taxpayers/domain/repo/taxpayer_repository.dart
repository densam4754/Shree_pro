import '../../../../core/utils/typedefs.dart';
import '../entities/taxpayer_entity.dart';

abstract class TaxpayerRepository {
  ResultFuture<List<TaxpayerEntity>> getAllTaxpayers();
}

