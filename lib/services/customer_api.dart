import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/customerss.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerApi {
  final String baseUrl = "http://38.242.196.127:1816/api";

  Future<List<Customerss>> getAllCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/setting/customer");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> customersJson = data['CustomResp']['CustomDtl'] ?? [];
        return customersJson.map((json) => Customerss.fromJson(json)).toList();
      } else {
        print("Error: ${response.statusCode} ${response.body}");
        return [];
      }
    } catch (e) {
      print("Exception: $e");
      return [];
    }
  }
}
