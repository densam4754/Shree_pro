import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shree_pro/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        return User.fromJson(data);
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}
