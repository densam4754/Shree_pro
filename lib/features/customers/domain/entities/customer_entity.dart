import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String name;
  final String id;
  final String email;
  final String phone;
  final String address;
  final String reference;
  final String created;
  final String status;

  const CustomerEntity({
    required this.name,
    required this.id,
    required this.email,
    required this.phone,
    required this.address,
    required this.reference,
    required this.created,
    required this.status,
  });

  @override
  List<Object> get props => [
        name,
        id,
        email,
        phone,
        address,
        reference,
        created,
        status,
      ];
}

