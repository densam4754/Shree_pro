part of 'insurance_bloc.dart';

abstract class InsuranceState extends Equatable {
  const InsuranceState();

  @override
  List<Object> get props => [];
}

class InsuranceInitial extends InsuranceState {}

class InsuranceLoading extends InsuranceState {}

class InsuranceRefreshing extends InsuranceState {}

class InsuranceLoaded extends InsuranceState {
  final List<InsuranceEntity> insurances;

  const InsuranceLoaded(this.insurances);

  @override
  List<Object> get props => [insurances];
}

class InsuranceError extends InsuranceState {
  final String message;

  const InsuranceError(this.message);

  @override
  List<Object> get props => [message];
}

