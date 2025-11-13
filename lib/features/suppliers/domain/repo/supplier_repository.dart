import '../../../../core/utils/typedefs.dart';
import '../entities/supplier_entity.dart';

abstract class SupplierRepository {
  ResultFuture<List<SupplierEntity>> getAllSuppliers();
}

