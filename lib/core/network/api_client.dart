import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client client;
  final SharedPreferences prefs;
  final FlutterSecureStorage secureStorage;
  
  ApiClient({
    required this.client,
    required this.prefs,
    required this.secureStorage,
  });
  
  Future<String?> getAccessToken() async {
    // Get token from secure storage
    return await secureStorage.read(key: ApiConstants.accessTokenKey);
  }
  
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
  
  Future<Map<String, String>> getFormHeaders() async {
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }
  
  Future<http.Response> get(String endpoint) async {
    try {
      final headers = await getAuthHeaders();
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
  
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
    bool useFormEncoding = false,
  }) async {
    try {
      final headers = customHeaders ?? 
          (useFormEncoding 
              ? await getFormHeaders() 
              : await getAuthHeaders());
      
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers,
        body: useFormEncoding 
            ? body?.map((k, v) => MapEntry(k, v.toString()))
            : jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
  
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw ServerException(
        response.body,
        response.statusCode,
      );
    }
  }
}

