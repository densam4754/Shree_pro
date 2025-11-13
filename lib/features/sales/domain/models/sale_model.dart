import '../entities/sale_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

class SaleModel extends SaleEntity {
  const SaleModel({
    required super.slId,
    required super.slTxIdNum,
    required super.subSpRefNum,
    required super.billAmt,
    required super.saleAmount,
    required super.costAmount,
    required super.profitAmount,
    required super.taxAmount,
    required super.slDesc,
    required super.slDt,
    required super.currency,
    required super.items,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['SaleItm'] as List<dynamic>? ?? const [];

    return SaleModel(
      slId: json['SlId']?.toString() ?? '',
      slTxIdNum: json['SlTxIdNum']?.toString() ?? '',
      subSpRefNum: json['SubSpRefNum']?.toString() ?? '',
      billAmt: _toDouble(json['BillAmt']),
      saleAmount: _toDouble(json['SlAmt']),
      costAmount: _toDouble(json['SlCstAmt']),
      profitAmount: _toDouble(json['SlPftAmt']),
      taxAmount: _toDouble(json['SlTxAmt']),
      slDesc: json['SlDesc']?.toString() ?? '',
      slDt: json['SlDt']?.toString() ?? '',
      currency: json['Ccy']?.toString() ?? '',
      items: itemsJson
          .map((item) => SaleItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SlId': slId,
      'SlTxIdNum': slTxIdNum,
      'SubSpRefNum': subSpRefNum,
      'BillAmt': billAmt,
      'SlAmt': saleAmount,
      'SlCstAmt': costAmount,
      'SlPftAmt': profitAmount,
      'SlTxAmt': taxAmount,
      'SlDesc': slDesc,
      'SlDt': slDt,
      'Ccy': currency,
      'SaleItm': items
          .map((item) => (item as SaleItemModel).toJson())
          .toList(),
    };
  }
}

class SaleItemModel extends SaleItemEntity {
  const SaleItemModel({
    required super.code,
    required super.name,
    required super.amount,
    required super.cost,
    required super.profit,
    required super.quantity,
    required super.unitCode,
    required super.taxCode,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      code: json['SlItmCode']?.toString() ?? '',
      name: json['SlItmNm']?.toString() ?? '',
      amount: _toDouble(json['SlItmAmt']),
      cost: _toDouble(json['SlItmCstAmt']),
      profit: _toDouble(json['SlItmPftAmt']),
      quantity: _toDouble(json['SlItmQty']),
      unitCode: json['SlItmQtyCode']?.toString() ?? '',
      taxCode: json['SlItmTxCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SlItmCode': code,
      'SlItmNm': name,
      'SlItmAmt': amount,
      'SlItmCstAmt': cost,
      'SlItmPftAmt': profit,
      'SlItmQty': quantity,
      'SlItmQtyCode': unitCode,
      'SlItmTxCode': taxCode,
    };
  }
}
