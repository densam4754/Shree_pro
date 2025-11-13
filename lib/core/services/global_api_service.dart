import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/exceptions.dart';
import '../utils/developer_logger.dart';
import 'api_endpoints.dart';

/// Global API Service
/// Handles all API communication and connection management
class GlobalApiService {
  final http.Client client;
  final FlutterSecureStorage secureStorage;
  
  GlobalApiService({
    required this.client,
    required this.secureStorage,
  });
  
  /// Get access token from secure storage
  Future<String?> getAccessToken() async {
    try {
      return await secureStorage.read(key: ApiEndpoints.accessTokenKey);
    } catch (e) {
      throw CacheException('Failed to get access token: $e');
    }
  }
  
  /// Get authentication headers
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    // Only add Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  /// Get form-encoded headers
  Map<String, String> getFormHeaders() {
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }
  
  /// GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? customHeaders,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final headers = customHeaders ?? await getAuthHeaders();
      
      // Log request
      log('GET $endpoint', tag: 'API');
      if (headers.isNotEmpty) {
        log('Headers: $headers', tag: 'API');
      }
      
      final response = await client.get(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: headers,
      );
      
      stopwatch.stop();
      
      // Log response with emoji based on status
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      log('GET $endpoint - Status: ${response.statusCode} - Duration: ${stopwatch.elapsed.inMilliseconds}ms', tag: 'API', isSuccess: isSuccess, isError: !isSuccess);
      if (response.body.isNotEmpty) {
        final bodyPreview = response.body.length > 200 
            ? '${response.body.substring(0, 200)}...' 
            : response.body;
        log('Response: $bodyPreview', tag: 'API', isSuccess: isSuccess, isError: !isSuccess);
      }
      
      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();
      
      // Log error
      log('GET $endpoint - Error: $e', tag: 'API', isError: true);
      
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }
  
  /// POST request
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
    bool useFormEncoding = false,
    bool requiresBasicAuth = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      Map<String, String> headers;
      
      if (customHeaders != null) {
        headers = customHeaders;
      } else if (requiresBasicAuth) {
        // For OAuth2 token endpoint, use Basic Auth
        headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': ApiEndpoints.basicAuth,
        };
      } else if (useFormEncoding) {
        headers = getFormHeaders();
      } else {
        headers = await getAuthHeaders();
      }
      
      // Log request
      log('POST $endpoint', tag: 'API');
      if (body != null) {
        final safeBody = Map<String, dynamic>.from(body);
        if (safeBody.containsKey('password')) {
          safeBody['password'] = '***';
        }
        log('Body: $safeBody', tag: 'API');
      }
      if (headers.isNotEmpty) {
        log('Headers: $headers', tag: 'API');
      }
      
      // For form encoding, convert Map<String, dynamic> to Map<String, String>
      // For JSON, encode as JSON string
      final response = await client.post(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: headers,
        body: useFormEncoding && body != null
            ? body.map((k, v) => MapEntry(k, v.toString()))
            : (body != null ? jsonEncode(body) : null),
      );
      
      stopwatch.stop();
      
      // Log response with emoji based on status
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      log('POST $endpoint - Status: ${response.statusCode} - Duration: ${stopwatch.elapsed.inMilliseconds}ms', tag: 'API', isSuccess: isSuccess, isError: !isSuccess);
      if (response.body.isNotEmpty) {
        final bodyPreview = response.body.length > 200 
            ? '${response.body.substring(0, 200)}...' 
            : response.body;
        log('Response: $bodyPreview', tag: 'API', isSuccess: isSuccess, isError: !isSuccess);
      }
      
      return _handleResponse(response);
    } catch (e) {
      stopwatch.stop();
      
      // Log error
      log('POST $endpoint - Error: $e', tag: 'API', isError: true);
      
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }
  
  /// PUT request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? customHeaders,
  }) async {
    try {
      final headers = customHeaders ?? await getAuthHeaders();
      final response = await client.put(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }
  
  /// DELETE request
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? customHeaders,
  }) async {
    try {
      final headers = customHeaders ?? await getAuthHeaders();
      final response = await client.delete(
        Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw NetworkException('Network error: $e');
    }
  }
  
  /// Handle HTTP response
  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      // Try to parse error message from JSON response
      String errorMessage = response.body;
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map<String, dynamic>) {
          // Extract error_description if available (OAuth2 format)
          if (errorData.containsKey('error_description')) {
            errorMessage = errorData['error_description'] as String;
          } else if (errorData.containsKey('message')) {
            errorMessage = errorData['message'] as String;
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'] as String;
          }
        }
      } catch (e) {
        // If parsing fails, use the raw body
        log('Failed to parse error response: $e', tag: 'API', isError: true);
      }
      
      log('API Error Response: ${response.statusCode} - $errorMessage', tag: 'API', isError: true);
      
      throw ServerException(
        errorMessage,
        response.statusCode,
      );
    }
  }
  
  /// Check connection health
  Future<bool> checkConnection() async {
    try {
      final response = await client.get(
        Uri.parse('${ApiEndpoints.baseUrl}/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

