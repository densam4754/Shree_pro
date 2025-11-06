import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Purchase.dart';

class PurchasesApi {
  final String baseUrl = "http://38.242.196.127:1816/api";

  Future<List<PurchaseDetail>> getAllPurchases() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/purchase");

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
        final List<dynamic> salesJson = data['PurcResp']?['PurcDtl'] ?? [];

        return salesJson.map((json) => PurchaseDetail.fromJson(json)).toList();
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
