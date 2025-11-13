import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/taxpayer.dart';

class TaxpayerApi {
  final String baseUrl = 'http://38.242.196.127:1816/api';

  Future<List<TaxpayerDetail>> getAllTaxpayers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return [];

    final url = Uri.parse('$baseUrl/setting/taxpayer');

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

        // Navigate into SpResp → SpDtl
        final List<dynamic> taxpayersJson = data['SpResp']?['SpDtl'] ?? [];

        return taxpayersJson
            .map((json) => TaxpayerDetail.fromJson(json))
            .toList();
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception: $e');
      return [];
    }
  }
}
