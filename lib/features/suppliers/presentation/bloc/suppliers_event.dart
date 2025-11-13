part of 'suppliers_bloc.dart';

abstract class SuppliersEvent extends Equatable {
  const SuppliersEvent();

  @override
  List<Object> get props => [];
}

class LoadSuppliers extends SuppliersEvent {
  const LoadSuppliers();
}

class RefreshSuppliers extends SuppliersEvent {
  const RefreshSuppliers();
}

