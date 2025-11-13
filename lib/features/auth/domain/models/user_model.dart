import '../entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.spName,
    required super.spRefNum,
    super.subSpName,
    required super.subSpRefNum,
    required super.accExpired,
    required super.accLocked,
    required super.accEnabled,
    required super.credExpired,
    required super.spAdmin,
    required super.topAdmin,
    super.passwordExpiryDate,
    required super.firstName,
    required super.lastName,
    required super.middleName,
    required super.phone,
    required super.phoneAlt,
    required super.email,
    required super.username,
    required super.address,
    required super.roleName,
    required super.roleDesc,
    required super.onlineFlag,
    super.generatedDate,
    required super.generatedBy,
    required super.approvedBy,
    super.approvedDate,
    required super.statusCode,
    required super.permissions,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json["UsrResp"]["UsrDtl"];

    return UserModel(
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
          .map((p) => PermissionModel.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "UsrResp": {
        "UsrDtl": {
          "SpNm": spName,
          "SpRefNum": spRefNum,
          "SubSpNm": subSpName,
          "SubSpRefNum": subSpRefNum,
          "AccExp": accExpired.toString(),
          "AccLock": accLocked.toString(),
          "AccEn": accEnabled.toString(),
          "CredExp": credExpired.toString(),
          "SpAdmin": spAdmin.toString(),
          "TopAdmin": topAdmin.toString(),
          "PsswdExpryDt": passwordExpiryDate?.toIso8601String(),
          "FNm": firstName,
          "LNm": lastName,
          "MNm": middleName,
          "PhNum": phone,
          "PhNum1": phoneAlt,
          "Email": email,
          "UsrNm": username,
          "Addrs": address,
          "RoleNm": roleName,
          "RoleDesc": roleDesc,
          "OnlFlag": onlineFlag.toString(),
          "GenDt": generatedDate?.toIso8601String(),
          "GenBy": generatedBy,
          "ApvdBy": approvedBy,
          "ApvdDt": approvedDate?.toIso8601String(),
          "StsCode": statusCode,
          "PermDtl": permissions.map((p) => (p as PermissionModel).toJson()).toList(),
        }
      }
    };
  }
}

class PermissionModel extends PermissionEntity {
  const PermissionModel({
    required super.name,
    required super.description,
    required super.generatedBy,
    required super.approvedBy,
    super.generatedDate,
    super.approvedDate,
    required super.statusCode,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
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

  Map<String, dynamic> toJson() {
    return {
      "PermNm": name,
      "PermDesc": description,
      "GenBy": generatedBy,
      "ApvdBy": approvedBy,
      "GenDt": generatedDate?.toIso8601String(),
      "ApvdDt": approvedDate?.toIso8601String(),
      "StsCode": statusCode,
    };
  }
}

