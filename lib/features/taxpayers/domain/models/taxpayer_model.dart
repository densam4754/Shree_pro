import '../entities/taxpayer_entity.dart';

class TaxpayerModel extends TaxpayerEntity {
  const TaxpayerModel({
    required super.spRefNum,
    required super.spName,
    required super.spDesc,
    required super.genDate,
    required super.genBy,
    required super.apvdDate,
    required super.apvdBy,
    required super.stsCode,
  });

  factory TaxpayerModel.fromJson(Map<String, dynamic> json) {
    return TaxpayerModel(
      spRefNum: json['SpRefNum'] ?? '',
      spName: json['SpNm'] ?? '',
      spDesc: json['SpDesc'] ?? '',
      genDate: json['GenDt'] ?? '',
      genBy: json['GenBy'] ?? '',
      apvdDate: json['ApvdDt'] ?? '',
      apvdBy: json['ApvdBy'] ?? '',
      stsCode: int.tryParse(json['StsCode']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SpRefNum': spRefNum,
      'SpNm': spName,
      'SpDesc': spDesc,
      'GenDt': genDate,
      'GenBy': genBy,
      'ApvdDt': apvdDate,
      'ApvdBy': apvdBy,
      'StsCode': stsCode,
    };
  }
}

