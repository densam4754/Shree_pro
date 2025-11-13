import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/supplier.dart';

class SupplierApi {
 
  final String baseUrl = "http://38.242.196.127:1816/api";

  Future<List<SupplierDetail>> getAllSuppliers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return [];

    final url = Uri.parse("$baseUrl/setting/supplier");

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
        // navigate into SupplResp -> SupplDtl
        final List<dynamic> supplierJson = data['SupplResp']?['SupplDtl'] ?? [];
        return supplierJson
            .map((json) => SupplierDetail.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // non-200 — log and return empty list (same style as your other APIs)
        print("SupplierApi Error: ${response.statusCode} ${response.body}");
        return [];
      }
    } catch (e) {
      print("SupplierApi Exception: $e");
      return [];
    }
  }
}
