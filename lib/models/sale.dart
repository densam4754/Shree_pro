// models/sale.dart
class SaleResponse {
  final List<SaleDetail> details;

  SaleResponse({required this.details});

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      details:
          (json['SlResp']['SlDtl'] as List)
              .map((e) => SaleDetail.fromJson(e))
              .toList(),
    );
  }
}

class SaleDetail {
  final String slId;
  final String slTxIdNum;
  final double billAmt;
  final String slDesc;
  final String slDt;
  // final double SlDiscAmt;
  final List<SaleItem> items;

  SaleDetail({
    required this.slId,
    required this.slTxIdNum,
    required this.billAmt,
    required this.slDesc,
    required this.slDt,
    // required this.SlDiscAmt,
    required this.items,
  });

  factory SaleDetail.fromJson(Map<String, dynamic> json) {
    return SaleDetail(
      slId: json['SlId'],
      slTxIdNum: json['SlTxIdNum'],
      billAmt: (json['BillAmt'] as num).toDouble(),
      slDesc: json['SlDesc'] ?? "",
      // SlDiscAmt: json['SlDiscAmt']?? "",
      slDt: json['SlDt'],
      items:
          (json['SaleItm'] as List).map((e) => SaleItem.fromJson(e)).toList(),
    );
  }
}

class SaleItem {
  final String code;
  final String name;
  final double amount;
  final double cost;
  final double profit;

  SaleItem({
    required this.code,
    required this.name,
    required this.amount,
    required this.cost,
    required this.profit,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      code: json['SlItmCode'],
      name: json['SlItmNm'],
      amount: (json['SlItmAmt'] as num).toDouble(),
      cost: (json['SlItmCstAmt'] as num).toDouble(),
      profit: (json['SlItmPftAmt'] as num).toDouble(),
    );
  }
}
