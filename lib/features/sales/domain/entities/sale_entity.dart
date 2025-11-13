import 'package:equatable/equatable.dart';

class SaleEntity extends Equatable {
  final String slId;
  final String slTxIdNum;
  final String subSpRefNum;
  final double billAmt;
  final double saleAmount;
  final double costAmount;
  final double profitAmount;
  final double taxAmount;
  final String slDesc;
  final String slDt;
  final String currency;
  final List<SaleItemEntity> items;

  const SaleEntity({
    required this.slId,
    required this.slTxIdNum,
    required this.subSpRefNum,
    required this.billAmt,
    required this.saleAmount,
    required this.costAmount,
    required this.profitAmount,
    required this.taxAmount,
    required this.slDesc,
    required this.slDt,
    required this.currency,
    required this.items,
  });

  @override
  List<Object> get props => [
        slId,
        slTxIdNum,
        subSpRefNum,
        billAmt,
        saleAmount,
        costAmount,
        profitAmount,
        taxAmount,
        slDesc,
        slDt,
        currency,
        items,
      ];
}

class SaleItemEntity extends Equatable {
  final String code;
  final String name;
  final double amount;
  final double cost;
  final double profit;
  final double quantity;
  final String unitCode;
  final String taxCode;

  const SaleItemEntity({
    required this.code,
    required this.name,
    required this.amount,
    required this.cost,
    required this.profit,
    required this.quantity,
    required this.unitCode,
    required this.taxCode,
  });

  @override
  List<Object> get props =>
      [code, name, amount, cost, profit, quantity, unitCode, taxCode];
}
