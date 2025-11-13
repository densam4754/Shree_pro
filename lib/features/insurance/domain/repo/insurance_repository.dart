import '../../../../core/utils/typedefs.dart';
import '../entities/insurance_entity.dart';

abstract class InsuranceRepository {
  ResultFuture<List<InsuranceEntity>> getAllInsurance();
}

