import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/purchase_entity.dart';
import '../repo/purchase_repository.dart';

class GetAllPurchasesUseCase extends UseCaseNoParams<List<PurchaseEntity>> {
  final PurchaseRepository repository;

  GetAllPurchasesUseCase(this.repository);

  @override
  ResultFuture<List<PurchaseEntity>> call() async {
    return await repository.getAllPurchases();
  }
}

