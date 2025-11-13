import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/device_group_entity.dart';
import '../repo/device_repository.dart';

class GetDevicesForCurrentCompanyUseCase
    extends UseCase<List<DeviceGroupEntity>, NoParams> {
  final DeviceRepository repository;

  GetDevicesForCurrentCompanyUseCase(this.repository);

  @override
  ResultFuture<List<DeviceGroupEntity>> call(NoParams params) {
    return repository.getDevicesForCurrentCompany();
  }
}

