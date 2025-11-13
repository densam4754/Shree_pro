import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/taxpayer_entity.dart';
import '../repo/taxpayer_repository.dart';

class GetAllTaxpayersUseCase extends UseCaseNoParams<List<TaxpayerEntity>> {
  final TaxpayerRepository repository;

  GetAllTaxpayersUseCase(this.repository);

  @override
  ResultFuture<List<TaxpayerEntity>> call() async {
    return await repository.getAllTaxpayers();
  }
}

