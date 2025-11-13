import 'package:equatable/equatable.dart';

import 'device_entity.dart';

class StationDeviceGroupEntity extends Equatable {
  final String subSpRefNum;
  final List<DeviceEntity> devices;

  const StationDeviceGroupEntity({
    required this.subSpRefNum,
    required this.devices,
  });

  @override
  List<Object?> get props => [subSpRefNum, devices];
}


