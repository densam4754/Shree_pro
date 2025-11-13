import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/sale_entity.dart';
import '../repo/sale_repository.dart';

class GetAllSalesUseCase extends UseCaseNoParams<List<SaleEntity>> {
  final SaleRepository repository;

  GetAllSalesUseCase(this.repository);

  @override
  ResultFuture<List<SaleEntity>> call() async {
    return await repository.getAllSales();
  }
}

