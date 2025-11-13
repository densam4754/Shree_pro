import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/supplier_entity.dart';
import '../repo/supplier_repository.dart';

class GetAllSuppliersUseCase extends UseCaseNoParams<List<SupplierEntity>> {
  final SupplierRepository repository;

  GetAllSuppliersUseCase(this.repository);

  @override
  ResultFuture<List<SupplierEntity>> call() async {
    return await repository.getAllSuppliers();
  }
}

