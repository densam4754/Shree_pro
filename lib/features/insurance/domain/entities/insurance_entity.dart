import 'package:equatable/equatable.dart';

class InsuranceEntity extends Equatable {
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

  const InsuranceEntity({
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

  @override
  List<Object> get props => [
        spRefNum,
        subSpRefNum,
        insCompCode,
        insCompNm,
        insRate,
        genBy,
        genDate,
        apvdBy,
        apvdDate,
        stsCode,
      ];
}

