class TaxpayerDetail {
  final String spRefNum;
  final String spName;
  final String spDesc;
  final String genDate;
  final String genBy;
  final String apvdDate;
  final String apvdBy;
  final int stsCode;

  TaxpayerDetail({
    required this.spRefNum,
    required this.spName,
    required this.spDesc,
    required this.genDate,
    required this.genBy,
    required this.apvdDate,
    required this.apvdBy,
    required this.stsCode,
  });

  factory TaxpayerDetail.fromJson(Map<String, dynamic> json) {
    return TaxpayerDetail(
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
}
