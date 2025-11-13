import '../../../../core/utils/typedefs.dart';
import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  ResultFuture<List<CustomerEntity>> getAllCustomers();
}

