import '../entities/supplier_entity.dart';

class SupplierModel extends SupplierEntity {
  const SupplierModel({
    required super.idTyp,
    required super.supplId,
    required super.supplName,
    required super.supplEmail,
    required super.supplPhone,
    required super.supplPhoneAlt,
    required super.supplAddress,
    required super.spRefNumber,
    required super.genDate,
    required super.genBy,
    required super.apvdBy,
    required super.apvdDate,
    required super.stsCode,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      idTyp: json['IdTyp']?.toString() ?? '',
      supplId: json['SupplId'] ?? '',
      supplName: json['SupplNm'] ?? json['SupplName'] ?? '',
      supplEmail: json['SupplEmail'] ?? '',
      supplPhone: json['SupplPh'] ?? '',
      supplPhoneAlt: json['SupplPh1'] ?? '',
      supplAddress: json['SupplAddrs'] ?? json['SupplAddress'] ?? '',
      spRefNumber: json['SpRefNum'] ?? '',
      genDate: json['GenDt'] ?? json['GenDate'] ?? '',
      genBy: json['GenBy'] ?? '',
      apvdBy: json['ApvdBy'] ?? '',
      apvdDate: json['ApvdDt'] ?? '',
      stsCode: (json['StsCode'] is int)
          ? json['StsCode'] as int
          : int.tryParse(json['StsCode']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdTyp': idTyp,
      'SupplId': supplId,
      'SupplNm': supplName,
      'SupplEmail': supplEmail,
      'SupplPh': supplPhone,
      'SupplPh1': supplPhoneAlt,
      'SupplAddrs': supplAddress,
      'SpRefNum': spRefNumber,
      'GenDt': genDate,
      'GenBy': genBy,
      'ApvdBy': apvdBy,
      'ApvdDt': apvdDate,
      'StsCode': stsCode,
    };
  }
}

