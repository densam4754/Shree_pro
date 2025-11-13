part of 'taxpayers_bloc.dart';

abstract class TaxpayersEvent extends Equatable {
  const TaxpayersEvent();

  @override
  List<Object> get props => [];
}

class LoadTaxpayers extends TaxpayersEvent {
  const LoadTaxpayers();
}

class RefreshTaxpayers extends TaxpayersEvent {
  const RefreshTaxpayers();
}

