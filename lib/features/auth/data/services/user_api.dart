import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';

class UserApi {
  final String baseUrl = "http://38.242.196.127:1816/api";

  Future<User?> getUserDetail(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token"); // ✅ get stored token

    if (token == null) {
      print("Error: No auth token found.");
      return null;
    }

    final url = Uri.parse("$baseUrl/user-management/$username");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': username}),
      );

      print("Requesting: $url");
      print("Status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data);
        
        // Save user data to SharedPreferences
        await _saveUserData(user, prefs);
        
        return user;
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  /// Save user data to SharedPreferences for offline access
  Future<void> _saveUserData(User user, SharedPreferences prefs) async {
    try {
      await prefs.setString('userEmail', user.email);
      await prefs.setString('userSpRefNum', user.spRefNum);
      await prefs.setString('userFirstName', user.firstName);
      await prefs.setString('userLastName', user.lastName);
      await prefs.setString('userMiddleName', user.middleName);
      await prefs.setString('userPhone', user.phone);
      await prefs.setString('userPhoneAlt', user.phoneAlt);
      await prefs.setString('userUsername', user.username);
      await prefs.setString('userAddress', user.address);
      await prefs.setString('userRoleName', user.roleName);
      await prefs.setString('userRoleDesc', user.roleDesc);
      await prefs.setBool('userDataCached', true);
      print("✅ User data saved to local storage");
    } catch (e) {
      print("⚠️ Failed to save user data: $e");
    }
  }

  /// Get cached user data from SharedPreferences
  /// Reads from keys used by AuthLocalDataSource (snake_case from ApiConstants)
  Future<User?> getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if any user data exists (check for email or username)
      final email = prefs.getString(ApiConstants.userEmailKey);
      final username = prefs.getString(ApiConstants.usernameKey);
      
      // If no user data exists, return null
      if (email == null && username == null) {
        return null;
      }

      // Read from keys used by AuthLocalDataSource (snake_case)
      return User(
        spName: prefs.getString(ApiConstants.userReferenceNumberKey) ?? '',
        spRefNum: prefs.getString(ApiConstants.userReferenceNumberKey) ?? '',
        subSpName: null,
        subSpRefNum: '',
        accExpired: false,
        accLocked: false,
        accEnabled: true,
        credExpired: false,
        spAdmin: false,
        topAdmin: false,
        passwordExpiryDate: null,
        firstName: prefs.getString(ApiConstants.userFirstNameKey) ?? '',
        lastName: prefs.getString(ApiConstants.userLastNameKey) ?? '',
        middleName: prefs.getString(ApiConstants.userMiddleNameKey) ?? '',
        phone: prefs.getString(ApiConstants.userPhone1Key) ?? '',
        phoneAlt: prefs.getString(ApiConstants.userPhone2Key) ?? '',
        email: prefs.getString(ApiConstants.userEmailKey) ?? '',
        username: prefs.getString(ApiConstants.usernameKey) ?? '',
        address: prefs.getString(ApiConstants.userAddressKey) ?? '',
        roleName: prefs.getString(ApiConstants.userRoleNameKey) ?? '',
        roleDesc: prefs.getString(ApiConstants.userRoleDescriptionKey) ?? '',
        onlineFlag: false,
        generatedDate: null,
        generatedBy: '',
        approvedBy: '',
        approvedDate: null,
        statusCode: 0,
        permissions: [],
      );
    } catch (e) {
      print("⚠️ Failed to get cached user data: $e");
      return null;
    }
  }
}
