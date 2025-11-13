import 'package:equatable/equatable.dart';

import 'station_device_group_entity.dart';

class DeviceGroupEntity extends Equatable {
  final String spRefNum;
  final String spName;
  final List<StationDeviceGroupEntity> stations;

  const DeviceGroupEntity({
    required this.spRefNum,
    required this.spName,
    required this.stations,
  });

  @override
  List<Object?> get props => [spRefNum, spName, stations];
}
