# Codebase Migration Plan

## Overview
Moving all models, services, and presentation screens from `lib/models/`, `lib/services/`, and `lib/presentation/pages/` to their respective feature folders following clean architecture.

## Migration Steps

### 1. Models Migration
- ✅ `lib/models/customerss.dart` → `lib/features/customers/domain/models/customerss_legacy.dart`
- ⏳ `lib/models/sale.dart` → `lib/features/sales/domain/models/sale_legacy.dart`
- ⏳ `lib/models/Purchase.dart` → `lib/features/purchases/domain/models/purchase_legacy.dart`
- ⏳ `lib/models/Suppliers.dart` → `lib/features/suppliers/domain/models/supplier_legacy.dart`
- ⏳ `lib/models/Taxpayer.dart` → `lib/features/taxpayers/domain/models/taxpayer_legacy.dart`
- ⏳ `lib/models/Insurance.dart` → `lib/features/insurance/domain/models/insurance_legacy.dart`
- ⏳ `lib/models/user.dart` → `lib/features/auth/domain/models/user_legacy.dart` (already exists as UserModel)

### 2. Services Migration
- ✅ `lib/services/customer_api.dart` → `lib/features/customers/data/services/customer_api_legacy.dart`
- ⏳ `lib/services/sale_api.dart` → `lib/features/sales/data/services/sale_api_legacy.dart`
- ⏳ `lib/services/Purchases_api.dart` → `lib/features/purchases/data/services/purchase_api_legacy.dart`
- ⏳ `lib/services/Supplier_api.dart` → `lib/features/suppliers/data/services/supplier_api_legacy.dart`
- ⏳ `lib/services/Taxpayer_api.dart` → `lib/features/taxpayers/data/services/taxpayer_api_legacy.dart`
- ⏳ `lib/services/Insurance_api.dart` → `lib/features/insurance/data/services/insurance_api_legacy.dart`
- ⏳ `lib/services/user_api.dart` → `lib/features/auth/data/services/user_api_legacy.dart`
- ⏳ `lib/services/auth_service.dart` → Already in `lib/features/auth/data/services/auth_service.dart`

### 3. Presentation Screens Migration
- ✅ Customers screens → `lib/features/customers/presentation/pages/`
- ⏳ Sales screens → `lib/features/sales/presentation/pages/`
- ⏳ Purchases screens → `lib/features/purchases/presentation/pages/`
- ⏳ Suppliers screens → `lib/features/suppliers/presentation/pages/`
- ⏳ Taxpayers screens → `lib/features/taxpayers/presentation/pages/`
- ⏳ Insurance screens → `lib/features/insurance/presentation/pages/`
- ⏳ Profile/Users screens → `lib/features/auth/presentation/pages/profile/` and `users/`

### 4. Import Updates
- Update imports in moved files
- Update imports in files that reference moved files (drawer.dart, main.dart, etc.)

### 5. Global Services
- Move shared/global services to `lib/core/services/`

## Notes
- Legacy models/services are kept for backward compatibility during migration
- Eventually, all code should migrate to use clean architecture models/services
- Old files in `lib/models/` and `lib/services/` can be removed after migration is complete

