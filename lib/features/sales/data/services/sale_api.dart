import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/sale.dart';

class SaleApi {
  final String baseUrl = "http://38.242.196.127:1816/api";

  Future<List<SaleDetail>> getAllSales() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/sale");

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

        // Navigate into SlResp → SlDtl
        final List<dynamic> salesJson = data['SlResp']?['SlDtl'] ?? [];

        return salesJson.map((json) => SaleDetail.fromJson(json)).toList();
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
