# Clean Architecture Structure

This project follows Clean Architecture principles with feature-based organization.

## Project Structure

```
lib/
├── core/                           # Core utilities and shared code
│   ├── constants/                 # App-wide constants
│   │   └── api_constants.dart     # API endpoints and keys
│   ├── errors/                     # Error handling
│   │   ├── exceptions.dart        # Exception classes
│   │   └── failures.dart          # Failure classes (for Either)
│   ├── injection/                 # Dependency injection
│   │   └── injection_container.dart
│   ├── network/                    # Network layer
│   │   ├── api_client.dart        # HTTP client wrapper
│   │   └── network_info.dart       # Network connectivity check
│   ├── usecases/                  # Base use case classes
│   │   └── usecase.dart
│   └── utils/                     # Utility functions
│       ├── input_validator.dart
│       └── typedefs.dart          # Type definitions
│
├── features/                       # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/                  # Data layer
│   │   │   ├── datasources/       # Data sources (remote/local)
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/            # Data models (extend entities)
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/      # Repository implementations
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/                # Domain layer (business logic)
│   │   │   ├── entities/         # Business entities (pure Dart)
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/     # Repository interfaces
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/         # Use cases (business logic)
│   │   │       ├── login_usecase.dart
│   │   │       ├── get_user_usecase.dart
│   │   │       └── logout_usecase.dart
│   │   └── presentation/         # Presentation layer (UI)
│   │       └── pages/
│   │           └── login_page.dart
│   │
│   ├── customers/                 # Customers feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── customer_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── customer_model.dart
│   │   │   └── repositories/
│   │   │       └── customer_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── customer_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── customer_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_all_customers_usecase.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── customers_page.dart
│   │       └── widgets/
│   │           └── customer_detail_dialog.dart
│   │
│   ├── sales/                     # Sales feature (similar structure)
│   ├── purchases/                 # Purchases feature
│   ├── suppliers/                 # Suppliers feature
│   ├── taxpayers/                 # Taxpayers feature
│   └── insurance/                 # Insurance feature
│
└── constants/                     # Legacy constants (migrate to core)
    ├── fonts.dart
    └── widgets/
```

## Architecture Layers

### 1. Domain Layer (Business Logic)
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Single-purpose business logic operations

**Dependencies**: None (pure Dart)

### 2. Data Layer (Data Management)
- **Models**: Extend entities, handle JSON serialization
- **Data Sources**: Remote (API) and Local (Cache) data sources
- **Repository Implementations**: Implement domain repository interfaces

**Dependencies**: Domain layer, Core layer

### 3. Presentation Layer (UI)
- **Pages**: Screen widgets
- **Widgets**: Reusable UI components
- **State Management**: Currently using StatefulWidget (can migrate to BLoC/Riverpod)

**Dependencies**: Domain layer (use cases only)

## Dependency Flow

```
Presentation → Domain ← Data
     ↓            ↑
   Use Cases   Entities
```

- Presentation depends on Domain (use cases)
- Data depends on Domain (implements repositories)
- Domain has NO dependencies (pure business logic)

## Key Principles

1. **Separation of Concerns**: Each layer has a single responsibility
2. **Dependency Inversion**: Dependencies point inward (Domain is independent)
3. **Testability**: Easy to test each layer independently
4. **Scalability**: Easy to add new features following the same pattern

## Adding a New Feature

1. Create feature folder: `lib/features/feature_name/`
2. Create domain layer:
   - `domain/entities/feature_entity.dart`
   - `domain/repositories/feature_repository.dart`
   - `domain/usecases/get_feature_usecase.dart`
3. Create data layer:
   - `data/models/feature_model.dart`
   - `data/datasources/feature_remote_datasource.dart`
   - `data/repositories/feature_repository_impl.dart`
4. Create presentation layer:
   - `presentation/pages/feature_page.dart`
   - `presentation/widgets/` (if needed)
5. Register dependencies in `injection_container.dart`

## Migration Status

✅ **Completed:**
- Core layer (errors, network, constants, DI, usecases)
- Auth feature (domain, data, presentation)
- Customer feature (domain, data, presentation)
- Sales feature (domain, data)
- Purchases feature (domain, data)
- Suppliers feature (domain, data)
- Taxpayers feature (domain, data)
- Insurance feature (domain, data)

📝 **To Do:**
- Update remaining presentation pages to use new use cases
- Migrate old presentation pages from lib/presentation to features
- Add state management (BLoC/Riverpod) - optional
- Add unit tests
- Add integration tests

## Notes

- Old files in `lib/models/`, `lib/services/`, `lib/api/` are kept for backward compatibility
- New clean architecture structure is in `lib/features/`
- Presentation pages can gradually migrate to use new use cases
- All dependencies are registered in `lib/core/injection/injection_container.dart`

