import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/customer_entity.dart';
import '../repo/customer_repository.dart';

class GetAllCustomersUseCase extends UseCaseNoParams<List<CustomerEntity>> {
  final CustomerRepository repository;

  GetAllCustomersUseCase(this.repository);

  @override
  ResultFuture<List<CustomerEntity>> call() async {
    return await repository.getAllCustomers();
  }
}

