# UseCases and DataSources - Functions and Responsibilities

## 📋 UseCases (Domain Layer)

**Location**: `lib/features/{feature}/domain/usecases/`

### Purpose:
UseCases contain **business logic** and orchestrate repository calls. They represent a single business action/operation.

### Functions:
1. **Encapsulate Business Logic**: Each use case represents one specific business operation
2. **Orchestrate Repository Calls**: Use cases call repository methods to get data
3. **Transform Data**: Can transform entities/data before returning to presentation layer
4. **Single Responsibility**: Each use case does ONE thing (e.g., `LoginUseCase`, `GetAllCustomersUseCase`)

### Example Flow:
```
Presentation (BLoC) 
    ↓ calls
UseCase (LoginUseCase)
    ↓ calls
Repository (AuthRepository)
    ↓ calls
DataSource (AuthRemoteDataSource)
    ↓ returns
Repository → UseCase → BLoC → UI
```

### Example:
```dart
class LoginUseCase extends UseCase<String, LoginParams> {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  @override
  ResultFuture<String> call(LoginParams params) async {
    // Business logic: Call repository to login
    return await repository.login(params.username, params.password);
  }
}
```

---

## 🔌 DataSources (Data Layer)

**Location**: `lib/features/{feature}/data/datasources/`

### Purpose:
DataSources handle **actual data fetching** from external sources (API, database, local storage).

### Types:
1. **Remote DataSource**: Fetches data from API/Network
   - Makes HTTP requests
   - Parses JSON responses
   - Returns Models (with JSON serialization)

2. **Local DataSource**: Fetches data from local storage
   - SharedPreferences
   - FlutterSecureStorage
   - SQLite/Hive
   - File system

### Functions:
1. **API Communication**: Make HTTP requests to backend
2. **Data Parsing**: Convert JSON to Models
3. **Error Handling**: Catch network/parsing errors and throw exceptions
4. **Caching**: Store/retrieve data locally
5. **Data Transformation**: Convert between formats (JSON ↔ Model)

### Example Flow:
```
Repository
    ↓ calls
RemoteDataSource (makes HTTP request)
    ↓ returns
Model (parsed from JSON)
    ↓ returns
Repository (converts Model → Entity)
    ↓ returns
UseCase → BLoC
```

### Example:
```dart
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  
  @override
  Future<String> login(String username, String password) async {
    // Make HTTP request
    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      body: {
        "username": username,
        "password": password,
      },
    );
    
    // Parse JSON response
    final data = jsonDecode(response.body);
    final accessToken = data["access_token"];
    
    // Return data (or throw exception on error)
    return accessToken as String;
  }
}
```

---

## 🔄 Complete Flow Example:

### Login Flow:

1. **UI (LoginPage)**: User clicks "Login" button
   ```dart
   context.read<AuthBloc>().add(LoginRequested(username, password));
   ```

2. **BLoC (AuthBloc)**: Handles event, calls use case
   ```dart
   final result = await loginUseCase(LoginParams(username, password));
   ```

3. **UseCase (LoginUseCase)**: Orchestrates repository call
   ```dart
   return await repository.login(params.username, params.password);
   ```

4. **Repository (AuthRepositoryImpl)**: Checks network, calls data source
   ```dart
   if (!await networkInfo.isConnected) {
     return Left(NetworkFailure('No internet connection'));
   }
   final token = await remoteDataSource.login(username, password);
   ```

5. **DataSource (AuthRemoteDataSourceImpl)**: Makes HTTP request
   ```dart
   final response = await apiClient.post(ApiConstants.loginEndpoint, ...);
   final accessToken = jsonDecode(response.body)["access_token"];
   return accessToken;
   ```

6. **Flow Back**: DataSource → Repository → UseCase → BLoC → UI

---

## 📊 Summary:

| Layer | Component | Responsibility |
|-------|-----------|----------------|
| **Domain** | UseCase | Business logic, orchestrates repository calls |
| **Data** | DataSource | Actual data fetching (API, local storage) |
| **Data** | Repository | Implements domain repository, calls data sources |
| **Domain** | Repository (abstract) | Defines contract (abstract methods) |

---

## ✅ Key Points:

- **UseCases**: One use case = One business operation
- **DataSources**: Handle actual data fetching (network/local)
- **Separation**: Business logic (UseCase) separate from data fetching (DataSource)
- **Testability**: Easy to test - mock data sources, test use cases independently

