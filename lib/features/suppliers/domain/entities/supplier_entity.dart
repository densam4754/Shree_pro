import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final String idTyp;
  final String supplId;
  final String supplName;
  final String supplEmail;
  final String supplPhone;
  final String supplPhoneAlt;
  final String supplAddress;
  final String spRefNumber;
  final String genDate;
  final String genBy;
  final String apvdBy;
  final String apvdDate;
  final int stsCode;

  const SupplierEntity({
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

  @override
  List<Object> get props => [
        idTyp,
        supplId,
        supplName,
        supplEmail,
        supplPhone,
        supplPhoneAlt,
        supplAddress,
        spRefNumber,
        genDate,
        genBy,
        apvdBy,
        apvdDate,
        stsCode,
      ];
}

