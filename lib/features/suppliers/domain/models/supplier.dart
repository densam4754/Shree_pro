class SupplierDetail {
  final String idTyp;
  final String supplId;
  final String supplName;
  final String supplEmail;
  final String supplPhone;
  final String supplPhoneAlt;
  final String supplAddress;
  final String spRefNumber;
  final String genDate; // used as genDate in your page
  final String genBy;
  final String apvdBy;
  final String apvdDate;
  final int stsCode;

  SupplierDetail({
    required this.idTyp,
    required this.supplId,
    required this.supplName,
    required this.supplEmail,
    required this.supplPhone,
    required this.supplPhoneAlt,
    required this.supplAddress,
    required this.spRefNumber,
    required this.genDate,
    required this.genBy,
    required this.apvdBy,
    required this.apvdDate,
    required this.stsCode,
  });

  factory SupplierDetail.fromJson(Map<String, dynamic> json) {
    return SupplierDetail(
      idTyp: json['IdTyp']?.toString() ?? '',
      supplId: json['SupplId'] ?? '',
      // server uses "SupplNm" -> map to supplName used in your UI
      supplName: json['SupplNm'] ?? json['SupplName'] ?? '',
      supplEmail: json['SupplEmail'] ?? '',
      // server uses "SupplPh" or "SupplPh1"
      supplPhone: json['SupplPh'] ?? '',
      supplPhoneAlt: json['SupplPh1'] ?? '',
      // server uses "SupplAddrs"
      supplAddress: json['SupplAddrs'] ?? json['SupplAddress'] ?? '',
      // server uses "SpRefNum"
      spRefNumber: json['SpRefNum'] ?? '',
      // server uses "GenDt"
      genDate: json['GenDt'] ?? json['GenDate'] ?? '',
      genBy: json['GenBy'] ?? '',
      apvdBy: json['ApvdBy'] ?? '',
      apvdDate: json['ApvdDt'] ?? '',
      stsCode: (json['StsCode'] is int)
          ? json['StsCode'] as int
          : int.tryParse(json['StsCode']?.toString() ?? '') ?? 0,
    );
  }
}
