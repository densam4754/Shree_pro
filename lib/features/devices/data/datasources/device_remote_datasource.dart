import '../../../../core/errors/exceptions.dart';
import '../models/device_model.dart';
import '../services/device_service.dart';

abstract class DeviceRemoteDataSource {
  Future<List<DeviceModel>> getDevicesBySpRef(String spRefNum);
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final DeviceService deviceService;

  DeviceRemoteDataSourceImpl({required this.deviceService});

  @override
  Future<List<DeviceModel>> getDevicesBySpRef(String spRefNum) async {
    try {
      return await deviceService.getDevicesBySpRef(spRefNum);
    } on AuthException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ServerException {
      rethrow;
    }
  }
}

