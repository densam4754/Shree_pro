part of 'taxpayers_bloc.dart';

abstract class TaxpayersState extends Equatable {
  const TaxpayersState();

  @override
  List<Object> get props => [];
}

class TaxpayersInitial extends TaxpayersState {}

class TaxpayersLoading extends TaxpayersState {}

class TaxpayersRefreshing extends TaxpayersState {}

class TaxpayersLoaded extends TaxpayersState {
  final List<TaxpayerEntity> taxpayers;

  const TaxpayersLoaded(this.taxpayers);

  @override
  List<Object> get props => [taxpayers];
}

class TaxpayersError extends TaxpayersState {
  final String message;

  const TaxpayersError(this.message);

  @override
  List<Object> get props => [message];
}

