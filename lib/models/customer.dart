class Customer {
  final String name;
  final String id;
  final String email;
  final String phone;
  final String address;

  Customer({
    required this.name,
    required this.id,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['CustomNm'] ?? '',
      id: json['CustomId'] ?? '',
      email: json['CustomEmail'] ?? '',
      phone: json['CustomPhNum'] ?? '',
      address: json['CustomAddrs'] ?? '',
    );
  }
}
