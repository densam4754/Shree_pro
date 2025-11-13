part of 'purchases_bloc.dart';

abstract class PurchasesEvent extends Equatable {
  const PurchasesEvent();

  @override
  List<Object> get props => [];
}

class LoadPurchases extends PurchasesEvent {
  const LoadPurchases();
}

class RefreshPurchases extends PurchasesEvent {
  const RefreshPurchases();
}

