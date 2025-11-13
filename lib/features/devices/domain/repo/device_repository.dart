import '../../../../core/utils/typedefs.dart';
import '../entities/device_group_entity.dart';

abstract class DeviceRepository {
  ResultFuture<List<DeviceGroupEntity>> getDevicesForCurrentCompany();
}

