import 'dart:convert';
import '../../../../core/services/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/developer_logger.dart';
import '../../../../core/services/global_api_service.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/models/user_model.dart';

/// Auth Service
/// Feature-specific service that uses direct HTTP calls (old working version)
class AuthService {
  final GlobalApiService globalApiService;
  final NetworkInfo networkInfo;

  AuthService({
    required this.globalApiService,
    required this.networkInfo,
  });

  /// Login user - using old working direct HTTP approach
  Future<String> login(String username, String password) async {
    final stopwatch = Stopwatch()..start();
    
    log('AuthService.login() - username: $username', tag: 'AuthService');
    
    // Step 1: Check network connection FIRST using NetworkChecker
    try {
      final isConnected = await NetworkChecker.checkConnection();
      if (!isConnected) {
        stopwatch.stop();
        log('AuthService.login() - No network connection', tag: 'AuthService', isError: true);
        throw const AuthException('No internet connection. Please check your network settings and try again.');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      stopwatch.stop();
      log('AuthService.login() - Network check failed: $e', tag: 'AuthService', isError: true);
      // If network check fails, provide helpful error message
      throw const AuthException('Unable to check network connection. Please try again.');
    }
    
    try {
      // Step 2: Network is connected, proceed with API call
      // API expects password with "+7" suffix, then base64 encoded
      // Check if password already ends with "+7" to avoid double suffix
      final passwordWithSuffix = password.endsWith('+7') ? password : '$password+7';
      final encodedPassword = base64Encode(utf8.encode(passwordWithSuffix));

      // Log request details (without password)
      log('POST ${ApiEndpoints.login}', tag: 'API');
      log('Username: $username', tag: 'API');
      log('Password: [hidden] → $passwordWithSuffix → base64 encoded', tag: 'API');

      final response = await globalApiService.post(
        ApiEndpoints.login,
        body: {
          "grant_type": "password",
          "username": username,
          "password": encodedPassword,
        },
        useFormEncoding: true,
        requiresBasicAuth: true,
      );

      log('Login Response: ${response.body}', tag: 'API', isSuccess: response.statusCode == 200, isError: response.statusCode != 200);

      stopwatch.stop();
      log('POST ${ApiEndpoints.login} - Status: ${response.statusCode} - Duration: ${stopwatch.elapsed.inMilliseconds}ms', tag: 'API', isSuccess: response.statusCode == 200, isError: response.statusCode != 200);
      
      // Step 3: Check response status and parse errors
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data["access_token"];

        if (accessToken == null) {
          log('Token not found in response', tag: 'AuthService', isError: true);
          throw const AuthException("Token not found in response");
        }

        log('AuthService.login() - Success - Duration: ${stopwatch.elapsed.inMilliseconds}ms', tag: 'AuthService', isSuccess: true);
        return accessToken as String;
      } else {
        // Parse error message from response
        String errorMessage = response.body;
        String? errorCode;
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic>) {
            // Extract error code
            if (errorData.containsKey('error')) {
              errorCode = errorData['error'] as String?;
            }
            // Extract error description/message
            if (errorData.containsKey('error_description')) {
              errorMessage = errorData['error_description'] as String;
            } else if (errorData.containsKey('message')) {
              errorMessage = errorData['message'] as String;
            } else if (errorCode != null) {
              errorMessage = errorCode;
            }
          }
        } catch (e) {
          // Use raw body if parsing fails
        }
        
        log('AuthService.login() - Error: $errorMessage (Code: $errorCode) - Status: ${response.statusCode}', tag: 'AuthService', isError: true);
        
        // Map specific error codes to user-friendly messages
        final userFriendlyMessage = _getUserFriendlyErrorMessage(errorCode, errorMessage, response.statusCode);
        throw AuthException(userFriendlyMessage);
      }
    } catch (e) {
      // Check if it's a ServerException first (most common case for API errors)
      if (e is ServerException) {
        stopwatch.stop();
        final serverEx = e;
        String errorMessage = serverEx.message;
        
        log('AuthService.login() - ServerException caught: $errorMessage - Status: ${serverEx.statusCode}', tag: 'AuthService', isError: true);
        
        // Extract error code from message (it should already be parsed by GlobalApiService)
        String? errorCode;
        final lowerMessage = errorMessage.toLowerCase();
        
        // Check if message contains error codes
        if (lowerMessage.contains('bad credentials') || 
            lowerMessage.contains('invalid_grant') ||
            lowerMessage.contains('invalid credentials')) {
          errorCode = 'bad_credentials';
        } else if (lowerMessage.contains('server_error') || 
                   lowerMessage.contains('internal server error')) {
          errorCode = 'server_error';
        } else if (lowerMessage.contains('unauthorized')) {
          errorCode = 'unauthorized';
        } else if (lowerMessage.contains('forbidden')) {
          errorCode = 'forbidden';
        }
        
        // Try to parse error code from JSON if message is JSON
        if (errorCode == null) {
          try {
            final errorData = jsonDecode(errorMessage);
            if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
              errorCode = errorData['error'] as String?;
            }
          } catch (parseError) {
            // Not JSON, use extracted errorCode or null
          }
        }
        
        log('AuthService.login() - Error Code: $errorCode, Message: $errorMessage', tag: 'AuthService', isError: true);
        
        // Map specific error codes to user-friendly messages
        final userFriendlyMessage = _getUserFriendlyErrorMessage(errorCode, errorMessage, serverEx.statusCode);
        throw AuthException(userFriendlyMessage);
      }
      
      // Handle other exception types
      if (e is AuthException) {
        stopwatch.stop();
        rethrow;
      }
      
      if (e is NetworkException) {
        stopwatch.stop();
        log('AuthService.login() - NetworkException: $e', tag: 'AuthService', isError: true);
        throw const AuthException('Network error. Please check your internet connection and try again.');
      }
      
      // Generic catch - check if error message contains useful info
      stopwatch.stop();
      final errorStr = e.toString();
      log('AuthService.login() - Failed: $e - Duration: ${stopwatch.elapsed.inMilliseconds}ms', tag: 'AuthService', isError: true);
      
      // Check if it's a ServerException wrapped in string
      if (errorStr.contains('ServerException') || errorStr.contains('Bad credentials') || errorStr.contains('invalid_grant')) {
        if (errorStr.contains('Bad credentials') || errorStr.contains('invalid_grant')) {
          throw const AuthException('Invalid username or password. Please check your credentials and try again.');
        }
      }
      
      throw const AuthException('Login failed. Please check your internet connection and try again.');
    }
  }

  /// Get user-friendly error message based on error code and message
  String _getUserFriendlyErrorMessage(String? errorCode, String errorMessage, int? statusCode) {
    final lowerCode = errorCode?.toLowerCase() ?? '';
    final lowerMessage = errorMessage.toLowerCase();
    
    // Check for specific error codes first
    if (lowerCode == 'bad_credentials' || 
        lowerCode == 'invalid_grant' ||
        lowerMessage.contains('bad credentials') || 
        lowerMessage.contains('invalid_grant') ||
        lowerMessage.contains('invalid credentials')) {
      return 'Invalid username or password. Please check your credentials and try again.';
    }
    
    if (lowerCode == 'server_error' || 
        lowerMessage.contains('server_error') ||
        lowerMessage.contains('internal server error')) {
      return 'Server error occurred. Please try again later.';
    }
    
    if (lowerCode == 'unauthorized' || 
        lowerMessage.contains('unauthorized') ||
        statusCode == 401) {
      return 'Authentication failed. Please check your credentials.';
    }
    
    if (lowerCode == 'forbidden' || 
        lowerMessage.contains('forbidden') ||
        statusCode == 403) {
      return 'Access denied. Please contact support.';
    }
    
    if (statusCode != null && statusCode >= 500) {
      return 'Server error occurred. Please try again later.';
    }
    
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return 'Invalid request. Please check your input and try again.';
    }
    
    // Default error message
    return errorMessage.isNotEmpty 
        ? errorMessage 
        : 'Login failed. Please try again.';
  }

  /// Validate access token
  Future<bool> validateToken(String token) async {
    try {
      // Check network connection using NetworkChecker
      final isConnected = await NetworkChecker.checkConnection();
      if (!isConnected) {
        log('AuthService.validateToken() - No network connection, cannot validate token', tag: 'AuthService');
        // If no internet, we cannot validate the token, so return false to require login
        return false;
      }

      // Network is available, proceed with API call to verify token
      try {
        final response = await globalApiService.get(
          ApiEndpoints.userManagement,
        );

        // If we get 401, token is expired or invalid
        if (response.statusCode == 401) {
          log('AuthService.validateToken() - Token expired or invalid (401)', tag: 'AuthService', isError: true);
          return false;
        }

        // 404 means endpoint doesn't exist - this doesn't mean token is invalid
        // We can't validate via this endpoint, but token might still be valid
        if (response.statusCode == 404) {
          log('AuthService.validateToken() - Validation endpoint not found (404). Assuming token is valid since endpoint may not exist.', tag: 'AuthService');
          // Return true to allow auto-login - token will be validated on actual API usage
          return true;
        }

        // Any 2xx status code means token is valid
        if (response.statusCode >= 200 && response.statusCode < 300) {
          log('AuthService.validateToken() - Token validation passed', tag: 'AuthService', isSuccess: true);
          return true;
        }

        // Other errors - assume token might be invalid
        log('AuthService.validateToken() - Token validation returned status: ${response.statusCode}', tag: 'AuthService');
        return false;
      } catch (e) {
        // Check if this is a ServerException
        if (e is ServerException) {
          // 401 means token is definitely expired or invalid
          if (e.statusCode == 401) {
            log('AuthService.validateToken() - Token expired or invalid (401 ServerException)', tag: 'AuthService', isError: true);
            return false;
          }
          
          // 404 means endpoint doesn't exist - this doesn't mean token is invalid
          // We can't validate via this endpoint, but token might still be valid
          if (e.statusCode == 404) {
            log('AuthService.validateToken() - Validation endpoint not found (404). Assuming token is valid since endpoint may not exist.', tag: 'AuthService');
            // Return true to allow auto-login - token will be validated on actual API usage
            return true;
          }
          
          // Other server errors - can't validate, assume invalid to be safe
          log('AuthService.validateToken() - Server error (${e.statusCode}): $e - cannot validate token', tag: 'AuthService', isError: true);
          return false;
        }
        
        // Check if this is a NetworkException (actual network error, not server error)
        if (e is NetworkException) {
          log('AuthService.validateToken() - Network error: $e - cannot validate token', tag: 'AuthService', isError: true);
          // For actual network errors, we cannot validate, so return false to require login
          return false;
        }
        
        // For other exceptions, log and return false to be safe
        log('AuthService.validateToken() - Unexpected error: $e - cannot validate token', tag: 'AuthService', isError: true);
        return false;
      }
    } catch (e) {
      log('AuthService.validateToken() - Error: $e - cannot validate token', tag: 'AuthService', isError: true);
      // On error, return false to require login
      return false;
    }
  }

  /// Get user information
  Future<UserModel> getUser(String username) async {
    final stopwatch = Stopwatch()..start();
    
    log('AuthService.getUser() - username: $username', tag: 'AuthService');
    
    try {
      final response = await globalApiService.post(
        '${ApiEndpoints.userManagement}/$username',
        body: {
          "username": username,
        },
      );

      stopwatch.stop();
      log('AuthService.getUser() - Success - Duration: ${stopwatch.elapsed.inMilliseconds}ms', tag: 'AuthService', isSuccess: true);

      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (e) {
      stopwatch.stop();
      if (e is AuthException) {
        rethrow;
      }
      log('AuthService.getUser() - Failed: $e - Duration: ${stopwatch.elapsed.inMilliseconds}ms', tag: 'AuthService', isError: true);
      throw AuthException('Failed to get user: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    // Logout is handled locally, no API call needed
  }
}

