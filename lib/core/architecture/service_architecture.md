# Service Architecture

## 📋 Overview

The application uses a **layered service architecture** where:
- **Global API Service**: Handles all API communication and connection management
- **Feature Services**: Each feature has its own service that uses the Global API Service
- **Data Sources**: Use feature services to fetch data

## 🏗️ Architecture Flow

```
Data Source
    ↓ uses
Feature Service (e.g., AuthService)
    ↓ uses
Global API Service
    ↓ uses
API Endpoints (api_endpoints.dart)
    ↓ makes
HTTP Requests
```

## 📁 Structure

### Global Services (`core/services/`)

#### `api_endpoints.dart`
- **Purpose**: Centralized API endpoints
- **Contains**: All API endpoint URLs and helper methods
- **Usage**: Imported by GlobalApiService and feature services

```dart
class ApiEndpoints {
  static const String baseUrl = "http://38.242.196.127:1816/api";
  static const String login = "/oauth/token";
  static const String customer = "/setting/customer";
  // ... more endpoints
}
```

#### `global_api_service.dart`
- **Purpose**: Handles all API communication
- **Responsibilities**:
  - HTTP request methods (GET, POST, PUT, DELETE)
  - Authentication header management
  - Token retrieval from secure storage
  - Response handling and error management
  - Connection health checks

```dart
class GlobalApiService {
  Future<http.Response> get(String endpoint);
  Future<http.Response> post(String endpoint, {body, useFormEncoding});
  Future<String?> getAccessToken();
  Future<bool> checkConnection();
}
```

### Feature Services (`features/{feature}/data/services/`)

Each feature has its own service that:
- Uses `GlobalApiService` for API calls
- Uses `ApiEndpoints` for endpoint URLs
- Handles feature-specific data parsing
- Converts JSON to Models

**Example**: `auth_service.dart`
```dart
class AuthService {
  final GlobalApiService globalApiService;
  
  Future<String> login(String username, String password) {
    final response = await globalApiService.post(
      ApiEndpoints.login,
      body: {...},
      useFormEncoding: true,
    );
    // Parse and return token
  }
}
```

## 🔄 Complete Flow Example

### Login Flow:

1. **Data Source** (`AuthRemoteDataSource`)
   ```dart
   return await authService.login(username, password);
   ```

2. **Feature Service** (`AuthService`)
   ```dart
   final response = await globalApiService.post(
     ApiEndpoints.login,
     body: {...},
   );
   ```

3. **Global API Service** (`GlobalApiService`)
   ```dart
   final headers = await getAuthHeaders();
   final response = await client.post(
     Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
     headers: headers,
     body: jsonEncode(body),
   );
   ```

4. **API Endpoints** (`ApiEndpoints`)
   ```dart
   static const String login = "/oauth/token";
   static const String baseUrl = "http://38.242.196.127:1816/api";
   ```

## ✅ Benefits

1. **Centralized API Management**: All endpoints in one place
2. **Single Source of Truth**: GlobalApiService handles all HTTP communication
3. **Feature Isolation**: Each feature has its own service
4. **Easy Testing**: Mock GlobalApiService for feature services
5. **Consistent Error Handling**: Global error handling in GlobalApiService
6. **Easy Maintenance**: Change base URL or headers in one place

## 📊 Service List

### Global Services
- ✅ `GlobalApiService` - Main API communication service
- ✅ `ApiEndpoints` - Centralized endpoint definitions

### Feature Services
- ✅ `AuthService` - Authentication operations
- ✅ `CustomerService` - Customer operations
- ✅ `SaleService` - Sale operations
- ✅ `PurchaseService` - Purchase operations
- ✅ `SupplierService` - Supplier operations
- ✅ `TaxpayerService` - Taxpayer operations
- ✅ `InsuranceService` - Insurance operations

## 🔧 Dependency Injection

All services are initialized in `injection_container.dart`:

```dart
// Initialize Global API Service
globalApiService = GlobalApiService(
  client: http.Client(),
  secureStorage: secureStorage,
);

// Initialize Feature Services
authService = AuthService(globalApiService: globalApiService);
customerService = CustomerService(globalApiService: globalApiService);
// ... more services

// Initialize Data Sources (use feature services)
authRemoteDataSource = AuthRemoteDataSourceImpl(authService: authService);
```

## 📝 Key Points

1. **GlobalApiService** is the single entry point for all API calls
2. **ApiEndpoints** contains all endpoint URLs
3. **Feature Services** use GlobalApiService and ApiEndpoints
4. **Data Sources** use Feature Services (not GlobalApiService directly)
5. All services are initialized in `injection_container.dart`

