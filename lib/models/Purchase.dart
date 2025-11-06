class PurchaseResponse {
  final List<PurchaseDetail> details;

  PurchaseResponse({required this.details});

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseResponse(
      details: (json['PurcResp']['PurcDtl'] as List)
          .map((e) => PurchaseDetail.fromJson(e))
          .toList(),
    );
  }
}

class PurchaseDetail {
  final String purchaseId;
  final String billAmount;
  final String purchaseAmout;
  final String curncy;
  final String purchaseQuantity;
  final String purchaseDate;
  final String supplierEmail;

  PurchaseDetail({
    required this.purchaseId,
    required this.billAmount,
    required this.purchaseAmout,
    required this.curncy,
    required this.purchaseQuantity,
    required this.purchaseDate,
    required this.supplierEmail,
  });

  factory PurchaseDetail.fromJson(Map<String, dynamic> json) {
    return PurchaseDetail(
      purchaseId: json['PurcId'].toString(),
      curncy: json['Ccy']?.toString() ?? "",
      billAmount: json['BillAmt'].toString(),
      purchaseAmout: json['PurcAmt'].toString(),
      purchaseQuantity: json['PurcQty'].toString(),
      purchaseDate: json['PurcGenDt'].toString(),
      supplierEmail: json['SupplEmail']?.toString() ?? "",
    );
  }
}

class PurchaseItem {
  final String purchaseItemCode;
  final String purchaseItemName;
  final String purchaseExpiryDate;

  PurchaseItem({
    required this.purchaseItemCode,
    required this.purchaseItemName,
    required this.purchaseExpiryDate,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      purchaseItemCode: json['PurcItmCode'].toString(),
      purchaseItemName: json['PurcItmNm'].toString(),
      purchaseExpiryDate: json['PurcItmExpryDt'].toString(),
    );
  }
}
