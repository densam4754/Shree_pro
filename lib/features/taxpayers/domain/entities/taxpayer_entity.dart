import 'package:equatable/equatable.dart';

class TaxpayerEntity extends Equatable {
  final String spRefNum;
  final String spName;
  final String spDesc;
  final String genDate;
  final String genBy;
  final String apvdDate;
  final String apvdBy;
  final int stsCode;

  const TaxpayerEntity({
    required this.spRefNum,
    required this.spName,
    required this.spDesc,
    required this.genDate,
    required this.genBy,
    required this.apvdDate,
    required this.apvdBy,
    required this.stsCode,
  });

  @override
  List<Object> get props => [
        spRefNum,
        spName,
        spDesc,
        genDate,
        genBy,
        apvdDate,
        apvdBy,
        stsCode,
      ];
}

