# Dependency Injection Container - Explanation

## 📋 What is Dependency Injection Container?

The **Injection Container** (also called Dependency Injection Container or DI Container) is a centralized place where all dependencies of the application are:
1. **Created/Initialized**
2. **Wired together**
3. **Made available** throughout the app

Think of it as a **factory** that creates and connects all the pieces of your application.

---

## 🎯 Purpose

### Without Dependency Injection:
```dart
// ❌ BAD: Creating dependencies directly in classes
class LoginPage {
  void login() {
    final apiClient = ApiClient(...);  // Hard to test!
    final repository = AuthRepository(...);  // Tightly coupled!
    // ...
  }
}
```

### With Dependency Injection:
```dart
// ✅ GOOD: Dependencies injected from container
class LoginPage {
  final AuthBloc authBloc;  // Injected from container
  
  LoginPage({required this.authBloc});  // Easy to test!
}
```

---

## 🔧 What Does `injection_container.dart` Do?

### 1. **Initializes Core Dependencies**
```dart
// Core infrastructure
late final SharedPreferences sharedPreferences;
late final FlutterSecureStorage secureStorage;
late final GlobalApiService globalApiService;
```

### 2. **Creates Feature Services**
```dart
// Feature-specific services
late final AuthService authService;
late final CustomerService customerService;
// ... more services
```

### 3. **Creates Data Sources**
```dart
// Data sources use services
late final AuthRemoteDataSource authRemoteDataSource;
late final AuthLocalDataSource authLocalDataSource;
// ... more data sources
```

### 4. **Creates Repositories**
```dart
// Repositories use data sources
late final AuthRepository authRepository;
late final CustomerRepository customerRepository;
// ... more repositories
```

### 5. **Creates Use Cases**
```dart
// Use cases use repositories
late final LoginUseCase loginUseCase;
late final GetAllCustomersUseCase getAllCustomersUseCase;
// ... more use cases
```

### 6. **Creates BLoCs**
```dart
// BLoCs use use cases
late final AuthBloc authBloc;
late final CustomersBloc customersBloc;
// ... more BLoCs
```

### 7. **Wires Everything Together**
```dart
Future<void> initDependencies() async {
  // Step 1: Initialize core dependencies
  sharedPreferences = await SharedPreferences.getInstance();
  secureStorage = FlutterSecureStorage(...);
  
  // Step 2: Initialize Global API Service
  globalApiService = GlobalApiService(...);
  
  // Step 3: Initialize Feature Services (use GlobalApiService)
  authService = AuthService(globalApiService: globalApiService);
  
  // Step 4: Initialize Data Sources (use Services)
  authRemoteDataSource = AuthRemoteDataSourceImpl(authService: authService);
  
  // Step 5: Initialize Repositories (use Data Sources)
  authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
    networkInfo: networkInfo,
  );
  
  // Step 6: Initialize Use Cases (use Repositories)
  loginUseCase = LoginUseCase(authRepository);
  
  // Step 7: Initialize BLoCs (use Use Cases)
  authBloc = AuthBloc(
    loginUseCase: loginUseCase,
    getUserUseCase: getUserUseCase,
    logoutUseCase: logoutUseCase,
  );
}
```

---

## 🔄 Dependency Flow

```
initDependencies() called in main.dart
    ↓
1. Core Dependencies (SharedPreferences, SecureStorage)
    ↓
2. GlobalApiService (uses SecureStorage)
    ↓
3. Feature Services (use GlobalApiService)
    ↓
4. Data Sources (use Feature Services)
    ↓
5. Repositories (use Data Sources)
    ↓
6. Use Cases (use Repositories)
    ↓
7. BLoCs (use Use Cases)
    ↓
Ready to use throughout the app!
```

---

## ✅ Benefits

### 1. **Single Source of Truth**
- All dependencies created in one place
- Easy to see what depends on what

### 2. **Easy Testing**
- Can easily swap real dependencies with mocks
- Test individual components in isolation

### 3. **Loose Coupling**
- Classes don't create their own dependencies
- Dependencies are injected from outside

### 4. **Centralized Configuration**
- Change how dependencies are created in one place
- Easy to update initialization logic

### 5. **Lifecycle Management**
- Control when dependencies are created
- Can create singletons (shared instances)

---

## 📝 Example Usage

### In `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all dependencies BEFORE running the app
  await initDependencies();
  
  runApp(MyApp());
}
```

### In a Page/Widget:
```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use the BLoC from injection container
    return BlocProvider.value(
      value: authBloc,  // From injection_container.dart
      child: LoginForm(),
    );
  }
}
```

---

## 🎯 Key Concepts

### **Dependency Injection (DI)**
- Instead of creating dependencies inside a class, they are **injected** from outside
- Makes code more testable and flexible

### **Dependency Injection Container**
- A **centralized place** that creates and manages all dependencies
- Ensures dependencies are created in the **correct order**
- Provides **singleton instances** (shared across the app)

### **Initialization Order**
The container ensures dependencies are created in the right order:
1. Core dependencies (SharedPreferences, SecureStorage)
2. Services (GlobalApiService, Feature Services)
3. Data Sources (use Services)
4. Repositories (use Data Sources)
5. Use Cases (use Repositories)
6. BLoCs (use Use Cases)

---

## 🔍 Real-World Analogy

Think of it like a **restaurant**:

- **Without DI Container**: Each chef goes to the market, buys ingredients, and cooks (chaos!)
- **With DI Container**: There's a **central kitchen** (container) that:
  1. Buys all ingredients (initializes dependencies)
  2. Prepares them in the right order
  3. Provides them to chefs when needed
  4. Ensures consistency across all dishes

---

## 📊 Summary

The `injection_container.dart`:
- ✅ **Creates** all dependencies
- ✅ **Wires** them together in the correct order
- ✅ **Provides** singleton instances
- ✅ **Manages** the lifecycle of dependencies
- ✅ **Makes** dependencies available throughout the app

It's the **foundation** that makes your Clean Architecture work smoothly!

