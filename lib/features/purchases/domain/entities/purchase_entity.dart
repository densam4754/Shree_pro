import 'package:equatable/equatable.dart';

class PurchaseEntity extends Equatable {
  final String purchaseId;
  final String billAmount;
  final String purchaseAmount;
  final String currency;
  final String purchaseQuantity;
  final String purchaseDate;
  final String supplierEmail;

  const PurchaseEntity({
    required this.purchaseId,
    required this.billAmount,
    required this.purchaseAmount,
    required this.currency,
    required this.purchaseQuantity,
    required this.purchaseDate,
    required this.supplierEmail,
  });

  @override
  List<Object> get props => [
        purchaseId,
        billAmount,
        purchaseAmount,
        currency,
        purchaseQuantity,
        purchaseDate,
        supplierEmail,
      ];
}

