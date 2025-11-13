import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' show KeychainAccessibility;
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/auth/domain/repo/auth_repository.dart';
import '../../features/auth/domain/usecases/get_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/validate_token_usecase.dart';
import '../../features/customers/data/datasources/customer_remote_datasource.dart';
import '../../features/customers/data/services/customer_service.dart';
import '../../features/customers/data/repository/customer_repository_impl.dart';
import '../../features/customers/domain/repo/customer_repository.dart';
import '../../features/customers/domain/usecases/get_all_customers_usecase.dart';
import '../../features/sales/data/datasources/sale_remote_datasource.dart';
import '../../features/sales/data/services/sale_service.dart';
import '../../features/sales/data/repository/sale_repository_impl.dart';
import '../../features/sales/domain/repo/sale_repository.dart';
import '../../features/sales/domain/usecases/get_all_sales_usecase.dart';
import '../../features/purchases/data/datasources/purchase_remote_datasource.dart';
import '../../features/purchases/data/services/purchase_service.dart';
import '../../features/purchases/data/repository/purchase_repository_impl.dart';
import '../../features/purchases/domain/repo/purchase_repository.dart';
import '../../features/purchases/domain/usecases/get_all_purchases_usecase.dart';
import '../../features/suppliers/data/datasources/supplier_remote_datasource.dart';
import '../../features/suppliers/data/services/supplier_service.dart';
import '../../features/suppliers/data/repository/supplier_repository_impl.dart';
import '../../features/suppliers/domain/repo/supplier_repository.dart';
import '../../features/suppliers/domain/usecases/get_all_suppliers_usecase.dart';
import '../../features/taxpayers/data/datasources/taxpayer_remote_datasource.dart';
import '../../features/taxpayers/data/services/taxpayer_service.dart';
import '../../features/taxpayers/data/repository/taxpayer_repository_impl.dart';
import '../../features/taxpayers/domain/repo/taxpayer_repository.dart';
import '../../features/taxpayers/domain/usecases/get_all_taxpayers_usecase.dart';
import '../../features/insurance/data/datasources/insurance_remote_datasource.dart';
import '../../features/insurance/data/services/insurance_service.dart';
import '../../features/insurance/data/repository/insurance_repository_impl.dart';
import '../../features/insurance/domain/repo/insurance_repository.dart';
import '../../features/insurance/domain/usecases/get_all_insurance_usecase.dart';
import '../../features/devices/data/services/device_service.dart';
import '../../features/devices/data/datasources/device_remote_datasource.dart';
import '../../features/devices/data/datasources/device_local_datasource.dart';
import '../../features/devices/data/repository/device_repository_impl.dart';
import '../../features/devices/domain/repo/device_repository.dart';
import '../../features/devices/domain/usecases/get_devices_for_current_company_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/customers/presentation/bloc/customers_bloc.dart';
import '../../features/sales/presentation/bloc/sales_bloc.dart';
import '../../features/purchases/presentation/bloc/purchases_bloc.dart';
import '../../features/suppliers/presentation/bloc/suppliers_bloc.dart';
import '../../features/taxpayers/presentation/bloc/taxpayers_bloc.dart';
import '../../features/insurance/presentation/bloc/insurance_bloc.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repository/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repo/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/check_onboarding_status_usecase.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_pages_usecase.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../services/global_api_service.dart';
import '../network/network_info.dart';

// Core dependencies
final networkInfo = NetworkInfoImpl();
late final SharedPreferences sharedPreferences;
late final FlutterSecureStorage secureStorage;

// Global API Service
late final GlobalApiService globalApiService;

// Feature Services
late final AuthService authService;
late final CustomerService customerService;
late final SaleService saleService;
late final PurchaseService purchaseService;
late final SupplierService supplierService;
late final TaxpayerService taxpayerService;
late final InsuranceService insuranceService;
late final DeviceService deviceService;

// Data sources
late final AuthRemoteDataSource authRemoteDataSource;
late final AuthLocalDataSource authLocalDataSource;
late final CustomerRemoteDataSource customerRemoteDataSource;
late final SaleRemoteDataSource saleRemoteDataSource;
late final PurchaseRemoteDataSource purchaseRemoteDataSource;
late final SupplierRemoteDataSource supplierRemoteDataSource;
late final TaxpayerRemoteDataSource taxpayerRemoteDataSource;
late final InsuranceRemoteDataSource insuranceRemoteDataSource;
late final DeviceRemoteDataSource deviceRemoteDataSource;
late final DeviceLocalDataSource deviceLocalDataSource;

// Repositories
late final AuthRepository authRepository;
late final CustomerRepository customerRepository;
late final SaleRepository saleRepository;
late final PurchaseRepository purchaseRepository;
late final SupplierRepository supplierRepository;
late final TaxpayerRepository taxpayerRepository;
late final InsuranceRepository insuranceRepository;
late final OnboardingRepository onboardingRepository;
late final DeviceRepository deviceRepository;

// Use cases
late final LoginUseCase loginUseCase;
late final GetUserUseCase getUserUseCase;
late final LogoutUseCase logoutUseCase;
late final ValidateTokenUseCase validateTokenUseCase;
late final GetAllCustomersUseCase getAllCustomersUseCase;
late final GetAllSalesUseCase getAllSalesUseCase;
late final GetAllPurchasesUseCase getAllPurchasesUseCase;
late final GetAllSuppliersUseCase getAllSuppliersUseCase;
late final GetAllTaxpayersUseCase getAllTaxpayersUseCase;
late final GetAllInsuranceUseCase getAllInsuranceUseCase;
late final GetDevicesForCurrentCompanyUseCase getDevicesForCurrentCompanyUseCase;
late final GetOnboardingPagesUseCase getOnboardingPagesUseCase;
late final CheckOnboardingStatusUseCase checkOnboardingStatusUseCase;
late final CompleteOnboardingUseCase completeOnboardingUseCase;

// BLoCs
late final AuthBloc authBloc;
late final CustomersBloc customersBloc;
late final SalesBloc salesBloc;
late final PurchasesBloc purchasesBloc;
late final SuppliersBloc suppliersBloc;
late final TaxpayersBloc taxpayersBloc;
late final InsuranceBloc insuranceBloc;
late final OnboardingBloc onboardingBloc;

Future<void> initDependencies() async {
  // Initialize SharedPreferences
  sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Secure Storage
  secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Initialize Global API Service
  globalApiService = GlobalApiService(
    client: http.Client(),
    secureStorage: secureStorage,
  );

        // Initialize Feature Services
        authService = AuthService(
          globalApiService: globalApiService,
          networkInfo: networkInfo,
        );
  customerService = CustomerService(globalApiService: globalApiService);
  saleService = SaleService(globalApiService: globalApiService);
  purchaseService = PurchaseService(globalApiService: globalApiService);
  supplierService = SupplierService(globalApiService: globalApiService);
  taxpayerService = TaxpayerService(globalApiService: globalApiService);
  insuranceService = InsuranceService(globalApiService: globalApiService);
  deviceService = DeviceService(globalApiService: globalApiService);

  // Initialize data sources
  authRemoteDataSource = AuthRemoteDataSourceImpl(authService: authService);
  authLocalDataSource = AuthLocalDataSourceImpl(
    prefs: sharedPreferences,
    secureStorage: secureStorage,
  );
  customerRemoteDataSource = CustomerRemoteDataSourceImpl(customerService: customerService);
  saleRemoteDataSource = SaleRemoteDataSourceImpl(saleService: saleService);
  purchaseRemoteDataSource = PurchaseRemoteDataSourceImpl(purchaseService: purchaseService);
  supplierRemoteDataSource = SupplierRemoteDataSourceImpl(supplierService: supplierService);
  taxpayerRemoteDataSource = TaxpayerRemoteDataSourceImpl(taxpayerService: taxpayerService);
  insuranceRemoteDataSource = InsuranceRemoteDataSourceImpl(insuranceService: insuranceService);
  deviceRemoteDataSource = DeviceRemoteDataSourceImpl(deviceService: deviceService);
  deviceLocalDataSource = DeviceLocalDataSourceImpl(prefs: sharedPreferences);

  // Initialize onboarding data source
  final onboardingLocalDataSource = OnboardingLocalDataSourceImpl(
    prefs: sharedPreferences,
  );

  // Initialize repositories
  authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
    networkInfo: networkInfo,
  );

  customerRepository = CustomerRepositoryImpl(
    remoteDataSource: customerRemoteDataSource,
    networkInfo: networkInfo,
  );

  saleRepository = SaleRepositoryImpl(
    remoteDataSource: saleRemoteDataSource,
    networkInfo: networkInfo,
  );

  purchaseRepository = PurchaseRepositoryImpl(
    remoteDataSource: purchaseRemoteDataSource,
    networkInfo: networkInfo,
  );

  supplierRepository = SupplierRepositoryImpl(
    remoteDataSource: supplierRemoteDataSource,
    networkInfo: networkInfo,
  );

  taxpayerRepository = TaxpayerRepositoryImpl(
    remoteDataSource: taxpayerRemoteDataSource,
    networkInfo: networkInfo,
  );

  insuranceRepository = InsuranceRepositoryImpl(
    remoteDataSource: insuranceRemoteDataSource,
    networkInfo: networkInfo,
  );

  onboardingRepository = OnboardingRepositoryImpl(
    localDataSource: onboardingLocalDataSource,
  );

  deviceRepository = DeviceRepositoryImpl(
    remoteDataSource: deviceRemoteDataSource,
    localDataSource: deviceLocalDataSource,
  );

  // Initialize use cases
  loginUseCase = LoginUseCase(authRepository);
  getUserUseCase = GetUserUseCase(authRepository);
  logoutUseCase = LogoutUseCase(authRepository);
  validateTokenUseCase = ValidateTokenUseCase(authRepository);
  getAllCustomersUseCase = GetAllCustomersUseCase(customerRepository);
  getAllSalesUseCase = GetAllSalesUseCase(saleRepository);
  getAllPurchasesUseCase = GetAllPurchasesUseCase(purchaseRepository);
  getAllSuppliersUseCase = GetAllSuppliersUseCase(supplierRepository);
  getAllTaxpayersUseCase = GetAllTaxpayersUseCase(taxpayerRepository);
  getAllInsuranceUseCase = GetAllInsuranceUseCase(insuranceRepository);
  getOnboardingPagesUseCase = GetOnboardingPagesUseCase(onboardingRepository);
  checkOnboardingStatusUseCase = CheckOnboardingStatusUseCase(onboardingRepository);
  completeOnboardingUseCase = CompleteOnboardingUseCase(onboardingRepository);
  getDevicesForCurrentCompanyUseCase =
      GetDevicesForCurrentCompanyUseCase(deviceRepository);

  // Initialize BLoCs
  authBloc = AuthBloc(
    loginUseCase: loginUseCase,
    getUserUseCase: getUserUseCase,
    logoutUseCase: logoutUseCase,
    validateTokenUseCase: validateTokenUseCase,
  );

  customersBloc = CustomersBloc(
    getAllCustomersUseCase: getAllCustomersUseCase,
  );

  salesBloc = SalesBloc(
    getAllSalesUseCase: getAllSalesUseCase,
  );

  purchasesBloc = PurchasesBloc(
    getAllPurchasesUseCase: getAllPurchasesUseCase,
  );

  suppliersBloc = SuppliersBloc(
    getAllSuppliersUseCase: getAllSuppliersUseCase,
  );

  taxpayersBloc = TaxpayersBloc(
    getAllTaxpayersUseCase: getAllTaxpayersUseCase,
  );

  insuranceBloc = InsuranceBloc(
    getAllInsuranceUseCase: getAllInsuranceUseCase,
  );

  onboardingBloc = OnboardingBloc(
    getOnboardingPagesUseCase: getOnboardingPagesUseCase,
    completeOnboardingUseCase: completeOnboardingUseCase,
  );
}

