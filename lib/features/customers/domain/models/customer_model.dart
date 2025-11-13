import '../entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.name,
    required super.id,
    required super.email,
    required super.phone,
    required super.address,
    required super.reference,
    required super.created,
    required super.status,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      name: json['CustomNm'] ?? '',
      id: json['CustomId'] ?? '',
      email: json['CustomEmail'] ?? '',
      phone: json['CustomPhNum'] ?? '',
      reference: json['SpRefNum'] ?? '',
      address: json['CustomAddrs'] ?? '',
      created: json['GenDt'] ?? '',
      status: json['StsCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CustomNm': name,
      'CustomId': id,
      'CustomEmail': email,
      'CustomPhNum': phone,
      'SpRefNum': reference,
      'CustomAddrs': address,
      'GenDt': created,
      'StsCode': status,
    };
  }
}

