import '../../domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.spRefNum,
    required super.spName,
    required super.subSpRefNum,
    required super.deviceCode,
    required super.deviceNumber,
    required super.deviceModelCode,
    required super.deviceId,
    super.deviceId1,
    super.deviceId2,
    super.deviceId3,
    required super.transactionLimit,
    required super.glCount,
    required super.purchaseGlCount,
    required super.adjustmentGlCount,
    required super.expenseGlCount,
    required super.generatedBy,
    super.generatedDate,
    required super.approvedBy,
    super.approvedDate,
    required super.statusCode,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return DeviceModel(
      spRefNum: json['SpRefNum']?.toString() ?? '',
      spName: json['SpNm']?.toString() ?? '',
      subSpRefNum: json['SubSpRefNum']?.toString() ?? '',
      deviceCode: json['DevCode']?.toString() ?? '',
      deviceNumber: json['DevNum']?.toString() ?? '',
      deviceModelCode: json['DevMdlCode']?.toString() ?? '',
      deviceId: json['DevId']?.toString() ?? '',
      deviceId1: json['DevId1']?.toString(),
      deviceId2: json['DevId2']?.toString(),
      deviceId3: json['DevId3']?.toString(),
      transactionLimit: (json['TrxLmt'] is num) ? (json['TrxLmt'] as num).toInt() : 0,
      glCount: (json['GlCt'] is num) ? (json['GlCt'] as num).toInt() : 0,
      purchaseGlCount:
          (json['PurcGlCt'] is num) ? (json['PurcGlCt'] as num).toInt() : 0,
      adjustmentGlCount:
          (json['AdjItmGlCt'] is num) ? (json['AdjItmGlCt'] as num).toInt() : 0,
      expenseGlCount:
          (json['ExpGlCt'] is num) ? (json['ExpGlCt'] as num).toInt() : 0,
      generatedBy: json['GenBy']?.toString() ?? '',
      generatedDate: parseDate(json['GenDt']),
      approvedBy: json['ApvdBy']?.toString() ?? '',
      approvedDate: parseDate(json['ApvdDt']),
      statusCode: json['StsCode']?.toString() ?? '',
    );
  }
}

