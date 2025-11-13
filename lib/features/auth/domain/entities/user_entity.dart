import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
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
  final List<PermissionEntity> permissions;

  const UserEntity({
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

  @override
  List<Object?> get props => [
        spName,
        spRefNum,
        subSpName,
        subSpRefNum,
        accExpired,
        accLocked,
        accEnabled,
        credExpired,
        spAdmin,
        topAdmin,
        passwordExpiryDate,
        firstName,
        lastName,
        middleName,
        phone,
        phoneAlt,
        email,
        username,
        address,
        roleName,
        roleDesc,
        onlineFlag,
        generatedDate,
        generatedBy,
        approvedBy,
        approvedDate,
        statusCode,
        permissions,
      ];
}

class PermissionEntity extends Equatable {
  final String name;
  final String description;
  final String generatedBy;
  final String approvedBy;
  final DateTime? generatedDate;
  final DateTime? approvedDate;
  final int statusCode;

  const PermissionEntity({
    required this.name,
    required this.description,
    required this.generatedBy,
    required this.approvedBy,
    this.generatedDate,
    this.approvedDate,
    required this.statusCode,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        generatedBy,
        approvedBy,
        generatedDate,
        approvedDate,
        statusCode,
      ];
}

