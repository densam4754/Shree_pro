import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<bool> get isConnected async {
    try {
      // Check connectivity status using connectivity_plus
      final List<ConnectivityResult> connectivityResults = 
          await _connectivity.checkConnectivity();
      
      // Return true if we have any connectivity (WiFi, mobile, ethernet, etc.)
      // Return false if no connectivity
      return !connectivityResults.contains(ConnectivityResult.none);
    } catch (e) {
      // If connectivity_plus fails, assume no connection
      return false;
    }
  }
}

/// Simple network checker utility class with DNS fallback verification
class NetworkChecker {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device is connected to network
  /// Uses connectivity_plus first, then DNS verification as fallback
  /// Returns true if connected, false if not connected
  static Future<bool> checkConnection() async {
    try {
      final List<ConnectivityResult> results = 
          await _connectivity.checkConnectivity();
      final hasConnectivityResult = !results.contains(ConnectivityResult.none);

      // If connectivity_plus says no connection, verify with DNS lookup as fallback
      if (!hasConnectivityResult) {
        return await _verifyInternetAccess();
      }

      return true;
    } catch (e) {
      // If connectivity_plus fails, try DNS fallback
      return await _verifyInternetAccess();
    }
  }

  /// Verify actual internet access using DNS lookup
  static Future<bool> _verifyInternetAccess() async {
    try {
      // Try to lookup a reliable DNS server
      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

