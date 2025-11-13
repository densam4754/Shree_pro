import '../entities/insurance_entity.dart';

class InsuranceModel extends InsuranceEntity {
  const InsuranceModel({
    required super.spRefNum,
    required super.subSpRefNum,
    required super.insCompCode,
    required super.insCompNm,
    required super.insRate,
    required super.genBy,
    required super.genDate,
    required super.apvdBy,
    required super.apvdDate,
    required super.stsCode,
  });

  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    return InsuranceModel(
      spRefNum: json['SpRefNum'] ?? '',
      subSpRefNum: json['SubSpRefNum'] ?? '',
      insCompCode: json['InsCompCode'] ?? '',
      insCompNm: json['InsCompNm'] ?? '',
      insRate: (json['InsRt'] ?? 0).toDouble(),
      genBy: json['GenBy'] ?? '',
      genDate: json['GenDt'] ?? '',
      apvdBy: json['ApvdBy'] ?? '',
      apvdDate: json['ApvdDt'] ?? '',
      stsCode: json['StsCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SpRefNum': spRefNum,
      'SubSpRefNum': subSpRefNum,
      'InsCompCode': insCompCode,
      'InsCompNm': insCompNm,
      'InsRt': insRate,
      'GenBy': genBy,
      'GenDt': genDate,
      'ApvdBy': apvdBy,
      'ApvdDt': apvdDate,
      'StsCode': stsCode,
    };
  }
}

