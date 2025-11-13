import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheAccessToken(String token);
  Future<void> cacheUsername(String username);
  Future<String?> getAccessToken();
  Future<String?> getUsername();
  Future<void> clearCache();
  Future<void> cacheUserProfile(UserEntity user);
  Future<void> deleteAccessToken();
  Future<void> deleteUsername();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({
    required this.prefs,
    required this.secureStorage,
  });

  @override
  Future<void> cacheAccessToken(String token) async {
    try {
      // Store token in secure storage
      await secureStorage.write(
        key: ApiConstants.accessTokenKey,
        value: token,
      );
      // Also store in SharedPreferences for quick access (non-sensitive data)
      await prefs.setBool('${ApiConstants.accessTokenKey}_exists', true);
    } catch (e) {
      throw CacheException('Failed to cache access token: $e');
    }
  }

  @override
  Future<void> cacheUsername(String username) async {
    try {
      // Store username in secure storage for better security
      await secureStorage.write(
        key: ApiConstants.usernameKey,
        value: username,
      );
      // Also keep a flag in SharedPreferences for quick checks
      await prefs.setBool('${ApiConstants.usernameKey}_exists', true);
    } catch (e) {
      throw CacheException('Failed to cache username: $e');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      // Get token from secure storage
      return await secureStorage.read(key: ApiConstants.accessTokenKey);
    } catch (e) {
      throw CacheException('Failed to get access token: $e');
    }
  }

  @override
  Future<String?> getUsername() async {
    try {
      // Get username from secure storage
      return await secureStorage.read(key: ApiConstants.usernameKey);
    } catch (e) {
      throw CacheException('Failed to get username: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Clear ALL secure storage keys
      await secureStorage.delete(key: ApiConstants.accessTokenKey);
      await secureStorage.delete(key: ApiConstants.usernameKey);
      
      // Also clear any legacy keys that might exist
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'username');
      await secureStorage.delete(key: 'refresh_token');
      
      // Clear ALL data from secure storage to be thorough
      await secureStorage.deleteAll();
      
      // Clear ALL SharedPreferences data to remove any cached user data
      await prefs.clear();
      
      // Small delay to ensure storage operations complete
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<void> cacheUserProfile(UserEntity user) async {
    try {
      await prefs.setString(ApiConstants.userEmailKey, user.email);
      await prefs.setString(ApiConstants.userReferenceNumberKey, user.spRefNum);
      await prefs.setString(ApiConstants.userFirstNameKey, user.firstName);
      await prefs.setString(ApiConstants.userLastNameKey, user.lastName);
      await prefs.setString(ApiConstants.userMiddleNameKey, user.middleName);
      await prefs.setString(ApiConstants.userPhone1Key, user.phone);
      await prefs.setString(ApiConstants.userPhone2Key, user.phoneAlt);
      await prefs.setString(ApiConstants.usernameKey, user.username);
      await prefs.setString(ApiConstants.userAddressKey, user.address);
      await prefs.setString(ApiConstants.userRoleNameKey, user.roleName);
      await prefs.setString(ApiConstants.userRoleDescriptionKey, user.roleDesc);
    } catch (e) {
      throw CacheException('Failed to cache user profile: $e');
    }
  }

  @override
  Future<void> deleteAccessToken() async {
    try {
      await secureStorage.delete(key: ApiConstants.accessTokenKey);
      await prefs.remove('${ApiConstants.accessTokenKey}_exists');
    } catch (e) {
      throw CacheException('Failed to delete access token: $e');
    }
  }

  @override
  Future<void> deleteUsername() async {
    try {
      await secureStorage.delete(key: ApiConstants.usernameKey);
      await prefs.remove('${ApiConstants.usernameKey}_exists');
    } catch (e) {
      throw CacheException('Failed to delete username: $e');
    }
  }
}

