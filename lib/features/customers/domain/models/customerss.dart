class Customerss {
  final String name;
  final String id;
  final String email;
  final String phone;
  final String address;
  final String   reference;
  final String created;
  final String status;

  Customerss({
    required this.name,
    required this.id,
    required this.email,
    required this.phone,
    required this.address,
    required this.reference,
    required this.created,
    required this.status
  });

  factory Customerss.fromJson(Map<String, dynamic> json) {
    return Customerss(
      name: json['CustomNm'] ?? '',
      id: json['CustomId'] ?? '',
      email: json['CustomEmail'] ?? '',
      phone: json['CustomPhNum'] ?? '',
      reference: json['SpRefNum'],
      address: json['CustomAddrs'] ?? '',
      created: json['GenDt']??'',
      status: json['StsCode']??'',
    );
  }
}
