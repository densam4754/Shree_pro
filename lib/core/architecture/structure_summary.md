# Clean Architecture Structure Summary

## ✅ Final Structure

### Domain Layer (`domain/`)
- **`repo/`**: Abstract repository interfaces (contracts)
  - Example: `AuthRepository`, `CustomerRepository`
  - Contains only abstract method signatures
  
- **`models/`**: Business models (extend entities)
  - Example: `UserModel`, `CustomerModel`, `InsuranceModel`
  - Contains JSON serialization (`fromJson`, `toJson`)
  - Extends entities
  
- **`entities/`**: Pure business entities
  - Example: `UserEntity`, `CustomerEntity`, `InsuranceEntity`
  - Pure data classes with no dependencies
  
- **`usecases/`**: Business logic orchestration
  - Example: `LoginUseCase`, `GetAllCustomersUseCase`
  - Orchestrates repository calls
  - Contains business logic

### Data Layer (`data/`)
- **`repository/`**: Concrete repository implementations
  - Example: `AuthRepositoryImpl`, `CustomerRepositoryImpl`
  - Implements domain repository interfaces
  - Contains all functionality/logic
  
- **`datasources/`**: Data fetching (API, local storage)
  - Example: `AuthRemoteDataSource`, `AuthLocalDataSource`
  - Makes HTTP requests
  - Parses JSON to Models
  - Handles caching

### Presentation Layer (`presentation/`)
- **`bloc/`**: State management (BLoC pattern)
- **`pages/`**: UI screens
- **`widgets/`**: Reusable UI components

---

## 📋 Responsibilities

### UseCases
- **Purpose**: Encapsulate business logic
- **Function**: Orchestrate repository calls
- **Location**: `domain/usecases/`
- **Example**: `LoginUseCase` calls `AuthRepository.login()`

### DataSources
- **Purpose**: Handle actual data fetching
- **Function**: 
  - Make HTTP requests (RemoteDataSource)
  - Read/write local storage (LocalDataSource)
  - Parse JSON to Models
- **Location**: `data/datasources/`
- **Example**: `AuthRemoteDataSource` makes POST request to login API

### Repositories
- **Domain (`repo/`)**: Abstract interfaces (contracts)
- **Data (`repository/`)**: Concrete implementations
  - Calls data sources
  - Converts Models to Entities
  - Handles error mapping

---

## 🔄 Data Flow

```
UI (Presentation)
    ↓
BLoC (State Management)
    ↓
UseCase (Business Logic)
    ↓
Repository (Data Access) [Domain: Abstract, Data: Implementation]
    ↓
DataSource (Data Fetching)
    ↓
API / Local Storage
```

---

## ✅ Key Points

1. **Domain `repo/`**: Abstract classes with abstract methods only
2. **Data `repository/`**: Concrete implementations with all functionality
3. **Domain `models/`**: Business models with JSON serialization
4. **Domain `entities/`**: Pure business entities
5. **UseCases**: One use case = One business operation
6. **DataSources**: Handle actual data fetching (network/local)

---

## 📁 Example Structure

```
lib/features/auth/
├── domain/
│   ├── repo/
│   │   └── auth_repository.dart (abstract)
│   ├── models/
│   │   └── user_model.dart (extends UserEntity, has JSON)
│   ├── entities/
│   │   └── user_entity.dart (pure data class)
│   └── usecases/
│       └── login_usecase.dart (business logic)
├── data/
│   ├── repository/
│   │   └── auth_repository_impl.dart (implements AuthRepository)
│   └── datasources/
│       ├── auth_remote_datasource.dart (HTTP requests)
│       └── auth_local_datasource.dart (local storage)
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

