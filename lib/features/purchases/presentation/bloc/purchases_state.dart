part of 'purchases_bloc.dart';

abstract class PurchasesState extends Equatable {
  const PurchasesState();

  @override
  List<Object> get props => [];
}

class PurchasesInitial extends PurchasesState {}

class PurchasesLoading extends PurchasesState {}

class PurchasesRefreshing extends PurchasesState {}

class PurchasesLoaded extends PurchasesState {
  final List<PurchaseEntity> purchases;

  const PurchasesLoaded(this.purchases);

  @override
  List<Object> get props => [purchases];
}

class PurchasesError extends PurchasesState {
  final String message;

  const PurchasesError(this.message);

  @override
  List<Object> get props => [message];
}

