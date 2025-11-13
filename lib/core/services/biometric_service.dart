import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../utils/developer_logger.dart';

/// Biometric Service
/// Handles biometric authentication (fingerprint, face ID, etc.)
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      log('Error checking device support: $e', tag: 'BiometricService', isError: true);
      return false;
    }
  }

  /// Check if biometrics are available (enrolled and ready)
  Future<bool> isBiometricsAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      log('Error checking biometric availability: $e', tag: 'BiometricService', isError: true);
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      log('Error getting available biometrics: $e', tag: 'BiometricService', isError: true);
      return [];
    }
  }

  /// Authenticate user with biometrics
  Future<bool> authenticate({
    String localizedReason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if device supports biometrics
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        log('Device does not support biometric authentication', tag: 'BiometricService', isError: true);
        return false;
      }

      // Check if biometrics are available
      final isAvailable = await isBiometricsAvailable();
      if (!isAvailable) {
        log('Biometrics are not available on this device', tag: 'BiometricService', isError: true);
        return false;
      }

      // Perform authentication
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        log('✅ Biometric authentication successful', tag: 'BiometricService', isSuccess: true);
      } else {
        log('Biometric authentication failed or was cancelled', tag: 'BiometricService', isError: true);
      }

      return didAuthenticate;
    } on PlatformException catch (e) {
      log('❌ Platform error during biometric authentication: $e', tag: 'BiometricService', isError: true);
      return false;
    } catch (e) {
      log('❌ Error during biometric authentication: $e', tag: 'BiometricService', isError: true);
      return false;
    }
  }

  /// Stop authentication (if in progress)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      log('Error stopping authentication: $e', tag: 'BiometricService', isError: true);
    }
  }
}

