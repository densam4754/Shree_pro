import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shree_pro/models/user.dart';

class AuthApi {
  final String baseUrl = "http://38.242.196.127:1816/api";

  /// 1. Login to get access token
  Future<bool> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/oauth/token");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          "grant_type": "password",
          "username": username,
          "password": password,
        },
      );

      print("Login Status: ${response.statusCode}");
      print("Login Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data["access_token"];

        if (accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("access_token", accessToken);
          await prefs.setString("username", username); // save username too
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  /// 2. Fetch user details
  Future<User?> fetchUser(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    if (token == null) return null;

    final url = Uri.parse("$baseUrl/user-management/$username");

    try {
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        print("User fetch failed: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Fetch User Error: $e");
      return null;
    }
  }

  /// Get token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
    await prefs.remove("username");
  }
}
