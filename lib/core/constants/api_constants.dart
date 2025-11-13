class ApiConstants {
  static const String baseUrl = "http://38.242.196.127:1816/api";
  
  // Auth endpoints
  static const String loginEndpoint = "/oauth/token";
  
  // User endpoints
  static const String userManagementEndpoint = "/user-management";
  
  // Setting endpoints
  static const String customerEndpoint = "/setting/customer";
  static const String supplierEndpoint = "/setting/supplier";
  static const String taxpayerEndpoint = "/setting/taxpayer";
  static const String insuranceEndpoint = "/setting/insurance";
  
  // Transaction endpoints
  static const String saleEndpoint = "/sale";
  static const String purchaseEndpoint = "/purchase";
  
  // Storage keys
  static const String accessTokenKey = "access_token";
  static const String usernameKey = "username";
  static const String userEmailKey = "user_email";
  static const String userReferenceNumberKey = "user_reference_number";
  static const String userFirstNameKey = "user_first_name";
  static const String userLastNameKey = "user_last_name";
  static const String userMiddleNameKey = "user_middle_name";
  static const String userPhone1Key = "user_phone_primary";
  static const String userPhone2Key = "user_phone_secondary";
  static const String userAddressKey = "user_address";
  static const String userRoleNameKey = "user_role_name";
  static const String userRoleDescriptionKey = "user_role_description";
}

