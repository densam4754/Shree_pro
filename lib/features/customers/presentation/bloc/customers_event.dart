part of 'customers_bloc.dart';

abstract class CustomersEvent extends Equatable {
  const CustomersEvent();

  @override
  List<Object> get props => [];
}

class LoadCustomers extends CustomersEvent {
  const LoadCustomers();
}

class RefreshCustomers extends CustomersEvent {
  const RefreshCustomers();
}

