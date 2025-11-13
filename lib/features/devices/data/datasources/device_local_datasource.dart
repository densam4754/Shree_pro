import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';

abstract class DeviceLocalDataSource {
  Future<String?> getCachedSpRefNum();
}

class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final SharedPreferences prefs;

  DeviceLocalDataSourceImpl({required this.prefs});

  @override
  Future<String?> getCachedSpRefNum() async {
    return prefs.getString(ApiConstants.userReferenceNumberKey);
  }
}

