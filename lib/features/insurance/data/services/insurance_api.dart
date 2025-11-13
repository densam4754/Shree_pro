import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/insurance.dart';

class InsuranceApi {
  final String baseUrl = "http://38.242.196.127:1816/api";

  Future<List<InsuranceDetail>> getAllInsurance() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/setting/insurance");

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

       
        final List<dynamic> InsuranceJson = data['InsResp']?['InsDtl'] ?? [];

        return InsuranceJson.map((json) => InsuranceDetail.fromJson(json)).toList();
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
