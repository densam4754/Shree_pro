// models/insurance.dart
class InsuranceResponse {
  final List<InsuranceDetail> details;

  InsuranceResponse({required this.details});

  factory InsuranceResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> insJson = json['InsResp']?['InsDtl'] ?? [];
    return InsuranceResponse(
      details: insJson.map((e) => InsuranceDetail.fromJson(e)).toList(),
    );
  }
}

class InsuranceDetail {
  final String spRefNum;
  final String subSpRefNum;
  final String insCompCode;
  final String insCompNm;
  final double insRate;
  final String genBy;
  final String genDate;
  final String apvdBy;
  final String apvdDate;
  final String stsCode;

  InsuranceDetail({
    required this.spRefNum,
    required this.subSpRefNum,
    required this.insCompCode,
    required this.insCompNm,
    required this.insRate,
    required this.genBy,
    required this.genDate,
    required this.apvdBy,
    required this.apvdDate,
    required this.stsCode,
  });

  factory InsuranceDetail.fromJson(Map<String, dynamic> json) {
    return InsuranceDetail(
      spRefNum: json['SpRefNum'] ?? '',
      subSpRefNum: json['SubSpRefNum'] ?? '',
      insCompCode: json['InsCompCode'] ?? '',
      insCompNm: json['InsCompNm'] ?? '',
      insRate: (json['InsRt'] ?? 0).toDouble(),
      genBy: json['GenBy'] ?? '',
      genDate: json['GenDt'] ?? '',
      apvdBy: json['ApvdBy'] ?? '',
      apvdDate: json['ApvdDt'] ?? '',
      stsCode: json['StsCode'] ?? '',
    );
  }
}
