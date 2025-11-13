import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/insurance_entity.dart';
import '../../domain/usecases/get_all_insurance_usecase.dart';

part 'insurance_event.dart';
part 'insurance_state.dart';

class InsuranceBloc extends Bloc<InsuranceEvent, InsuranceState> {
  final GetAllInsuranceUseCase getAllInsuranceUseCase;

  InsuranceBloc({required this.getAllInsuranceUseCase})
      : super(InsuranceInitial()) {
    on<LoadInsurance>(_onLoadInsurance);
    on<RefreshInsurance>(_onRefreshInsurance);
  }

  Future<void> _onLoadInsurance(
    LoadInsurance event,
    Emitter<InsuranceState> emit,
  ) async {
    emit(InsuranceLoading());

    final result = await getAllInsuranceUseCase();

    result.fold(
      (failure) => emit(InsuranceError(failure.message)),
      (insurances) => emit(InsuranceLoaded(insurances)),
    );
  }

  Future<void> _onRefreshInsurance(
    RefreshInsurance event,
    Emitter<InsuranceState> emit,
  ) async {
    emit(InsuranceRefreshing());

    final result = await getAllInsuranceUseCase();

    result.fold(
      (failure) => emit(InsuranceError(failure.message)),
      (insurances) => emit(InsuranceLoaded(insurances)),
    );
  }
}

