import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final String spRefNum;
  final String spName;
  final String subSpRefNum;
  final String deviceCode;
  final String deviceNumber;
  final String deviceModelCode;
  final String deviceId;
  final String? deviceId1;
  final String? deviceId2;
  final String? deviceId3;
  final int transactionLimit;
  final int glCount;
  final int purchaseGlCount;
  final int adjustmentGlCount;
  final int expenseGlCount;
  final String generatedBy;
  final DateTime? generatedDate;
  final String approvedBy;
  final DateTime? approvedDate;
  final String statusCode;

  const DeviceEntity({
    required this.spRefNum,
    required this.spName,
    required this.subSpRefNum,
    required this.deviceCode,
    required this.deviceNumber,
    required this.deviceModelCode,
    required this.deviceId,
    this.deviceId1,
    this.deviceId2,
    this.deviceId3,
    required this.transactionLimit,
    required this.glCount,
    required this.purchaseGlCount,
    required this.adjustmentGlCount,
    required this.expenseGlCount,
    required this.generatedBy,
    this.generatedDate,
    required this.approvedBy,
    this.approvedDate,
    required this.statusCode,
  });

  @override
  List<Object?> get props => [
        spRefNum,
        spName,
        subSpRefNum,
        deviceCode,
        deviceNumber,
        deviceModelCode,
        deviceId,
        deviceId1,
        deviceId2,
        deviceId3,
        transactionLimit,
        glCount,
        purchaseGlCount,
        adjustmentGlCount,
        expenseGlCount,
        generatedBy,
        generatedDate,
        approvedBy,
        approvedDate,
        statusCode,
      ];
}

