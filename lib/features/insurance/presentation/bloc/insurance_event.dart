part of 'insurance_bloc.dart';

abstract class InsuranceEvent extends Equatable {
  const InsuranceEvent();

  @override
  List<Object> get props => [];
}

class LoadInsurance extends InsuranceEvent {
  const LoadInsurance();
}

class RefreshInsurance extends InsuranceEvent {
  const RefreshInsurance();
}

