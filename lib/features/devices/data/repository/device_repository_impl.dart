import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/device_group_entity.dart';
import '../../domain/entities/station_device_group_entity.dart';
import '../../domain/repo/device_repository.dart';
import '../datasources/device_local_datasource.dart';
import '../datasources/device_remote_datasource.dart';
import '../models/device_model.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;
  final DeviceLocalDataSource localDataSource;

  DeviceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  ResultFuture<List<DeviceGroupEntity>> getDevicesForCurrentCompany() async {
    try {
      final spRefNum = await localDataSource.getCachedSpRefNum();

      if (spRefNum == null || spRefNum.isEmpty) {
        return const Left(CacheFailure('No cached reference number found.'));
      }

      final devices = await remoteDataSource.getDevicesBySpRef(spRefNum);

      final grouped = _groupDevicesByCompany(devices);
      return Right(grouped);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  List<DeviceGroupEntity> _groupDevicesByCompany(List<DeviceModel> devices) {
    final Map<String, List<DeviceModel>> byCompany = {};
    for (final device in devices) {
      byCompany.putIfAbsent(device.spRefNum, () => []).add(device);
    }

    final List<DeviceGroupEntity> result = [];

    byCompany.forEach((spRef, companyDevices) {
      final Map<String, List<DeviceModel>> byStation = {};
      for (final device in companyDevices) {
        byStation.putIfAbsent(device.subSpRefNum, () => []).add(device);
      }

      final stations = byStation.entries.map((entry) {
        return StationDeviceGroupEntity(
          subSpRefNum: entry.key,
          devices: entry.value,
        );
      }).toList();

      final first = companyDevices.first;
      result.add(
        DeviceGroupEntity(
          spRefNum: first.spRefNum,
          spName: first.spName,
          stations: stations,
        ),
      );
    });

    return result;
  }
}

