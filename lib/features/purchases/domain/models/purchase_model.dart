import '../entities/purchase_entity.dart';

class PurchaseModel extends PurchaseEntity {
  const PurchaseModel({
    required super.purchaseId,
    required super.billAmount,
    required super.purchaseAmount,
    required super.currency,
    required super.purchaseQuantity,
    required super.purchaseDate,
    required super.supplierEmail,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      purchaseId: json['PurcId'].toString(),
      currency: json['Ccy']?.toString() ?? "",
      billAmount: json['BillAmt'].toString(),
      purchaseAmount: json['PurcAmt'].toString(),
      purchaseQuantity: json['PurcQty'].toString(),
      purchaseDate: json['PurcGenDt'].toString(),
      supplierEmail: json['SupplEmail']?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PurcId': purchaseId,
      'Ccy': currency,
      'BillAmt': billAmount,
      'PurcAmt': purchaseAmount,
      'PurcQty': purchaseQuantity,
      'PurcGenDt': purchaseDate,
      'SupplEmail': supplierEmail,
    };
  }
}

