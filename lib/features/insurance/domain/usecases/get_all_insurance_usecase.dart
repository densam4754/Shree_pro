import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/insurance_entity.dart';
import '../repo/insurance_repository.dart';

class GetAllInsuranceUseCase extends UseCaseNoParams<List<InsuranceEntity>> {
  final InsuranceRepository repository;

  GetAllInsuranceUseCase(this.repository);

  @override
  ResultFuture<List<InsuranceEntity>> call() async {
    return await repository.getAllInsurance();
  }
}

