// Legacy model for backward compatibility
// TODO: Migrate to UserModel
class User {
  final String spName;
  final String spRefNum;
  final String? subSpName;
  final String subSpRefNum;
  final bool accExpired;
  final bool accLocked;
  final bool accEnabled;
  final bool credExpired;
  final bool spAdmin;
  final bool topAdmin;
  final DateTime? passwordExpiryDate;
  final String firstName;
  final String lastName;
  final String middleName;
  final String phone;
  final String phoneAlt;
  final String email;
  final String username;
  final String address;
  final String roleName;
  final String roleDesc;
  final bool onlineFlag;
  final DateTime? generatedDate;
  final String generatedBy;
  final String approvedBy;
  final DateTime? approvedDate;
  final int statusCode;
  final List<Permission> permissions;

  User({
    required this.spName,
    required this.spRefNum,
    this.subSpName,
    required this.subSpRefNum,
    required this.accExpired,
    required this.accLocked,
    required this.accEnabled,
    required this.credExpired,
    required this.spAdmin,
    required this.topAdmin,
    this.passwordExpiryDate,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.phone,
    required this.phoneAlt,
    required this.email,
    required this.username,
    required this.address,
    required this.roleName,
    required this.roleDesc,
    required this.onlineFlag,
    this.generatedDate,
    required this.generatedBy,
    required this.approvedBy,
    this.approvedDate,
    required this.statusCode,
    required this.permissions,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userJson = json["UsrResp"]["UsrDtl"];

    return User(
      spName: userJson["SpNm"] ?? "",
      spRefNum: userJson["SpRefNum"] ?? "",
      subSpName: userJson["SubSpNm"],
      subSpRefNum: userJson["SubSpRefNum"] ?? "",
      accExpired: userJson["AccExp"] == "true",
      accLocked: userJson["AccLock"] == "true",
      accEnabled: userJson["AccEn"] == "true",
      credExpired: userJson["CredExp"] == "true",
      spAdmin: userJson["SpAdmin"] == "true",
      topAdmin: userJson["TopAdmin"] == "true",
      passwordExpiryDate: userJson["PsswdExpryDt"] != null
          ? DateTime.tryParse(userJson["PsswdExpryDt"])
          : null,
      firstName: userJson["FNm"] ?? "",
      lastName: userJson["LNm"] ?? "",
      middleName: userJson["MNm"] ?? "",
      phone: userJson["PhNum"] ?? "",
      phoneAlt: userJson["PhNum1"] ?? "",
      email: userJson["Email"] ?? "",
      username: userJson["UsrNm"] ?? "",
      address: userJson["Addrs"] ?? "",
      roleName: userJson["RoleNm"] ?? "",
      roleDesc: userJson["RoleDesc"] ?? "",
      onlineFlag: userJson["OnlFlag"] == "true",
      generatedDate: userJson["GenDt"] != null
          ? DateTime.tryParse(userJson["GenDt"])
          : null,
      generatedBy: userJson["GenBy"] ?? "",
      approvedBy: userJson["ApvdBy"] ?? "",
      approvedDate: userJson["ApvdDt"] != null
          ? DateTime.tryParse(userJson["ApvdDt"])
          : null,
      statusCode: userJson["StsCode"] ?? 0,
      permissions: (userJson["PermDtl"] as List<dynamic>)
          .map((p) => Permission.fromJson(p))
          .toList(),
    );
  }
}

class Permission {
  final String name;
  final String description;
  final String generatedBy;
  final String approvedBy;
  final DateTime? generatedDate;
  final DateTime? approvedDate;
  final int statusCode;

  Permission({
    required this.name,
    required this.description,
    required this.generatedBy,
    required this.approvedBy,
    this.generatedDate,
    this.approvedDate,
    required this.statusCode,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      name: json["PermNm"] ?? "",
      description: json["PermDesc"] ?? "",
      generatedBy: json["GenBy"] ?? "",
      approvedBy: json["ApvdBy"] ?? "",
      generatedDate: json["GenDt"] != null
          ? DateTime.tryParse(json["GenDt"])
          : null,
      approvedDate: json["ApvdDt"] != null
          ? DateTime.tryParse(json["ApvdDt"])
          : null,
      statusCode: json["StsCode"] ?? 0,
    );
  }
}

