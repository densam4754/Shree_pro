/// Global API Endpoints
/// All API endpoints are centralized here for easy management
class ApiEndpoints {
  // Base URL
  static const String baseUrl = "http://38.242.196.127:1816/api";

  // OAuth2 Client Credentials (Basic Auth)
  static const String oauthClientId = "mobile-device";
  static const String oauthClientSecret = "mauzo@Service";
  static const String basicAuth = "Basic bW9iaWxlLWRldmljZTptYXV6b0BTZXJ2aWNl";

  // Auth Endpoints
  static const String login = "/oauth/token";
  static const String logout = "/oauth/logout";
  
  // User Management Endpoints
  static const String userManagement = "/user-management";
  
  // Setting Endpoints
  static const String customer = "/setting/customer";
  static const String supplier = "/setting/supplier";
  static const String taxpayer = "/setting/taxpayer";
  static const String insurance = "/setting/insurance";
  static const String device = "/setting/device";
  static String deviceBySpRef(String spRefNum) => "/setting/device/sp/$spRefNum";
  
  // Transaction Endpoints
  static const String sale = "/sale";
  static const String purchase = "/purchase";
  
  // Storage Keys
  static const String accessTokenKey = "access_token";
  static const String usernameKey = "username";
  
  // Helper methods for dynamic endpoints
  static String getUser(String username) => "$userManagement/$username";
}

