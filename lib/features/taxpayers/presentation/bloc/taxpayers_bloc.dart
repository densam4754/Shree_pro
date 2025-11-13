import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/taxpayer_entity.dart';
import '../../domain/usecases/get_all_taxpayers_usecase.dart';

part 'taxpayers_event.dart';
part 'taxpayers_state.dart';

class TaxpayersBloc extends Bloc<TaxpayersEvent, TaxpayersState> {
  final GetAllTaxpayersUseCase getAllTaxpayersUseCase;

  TaxpayersBloc({required this.getAllTaxpayersUseCase})
      : super(TaxpayersInitial()) {
    on<LoadTaxpayers>(_onLoadTaxpayers);
    on<RefreshTaxpayers>(_onRefreshTaxpayers);
  }

  Future<void> _onLoadTaxpayers(
    LoadTaxpayers event,
    Emitter<TaxpayersState> emit,
  ) async {
    emit(TaxpayersLoading());

    final result = await getAllTaxpayersUseCase();

    result.fold(
      (failure) => emit(TaxpayersError(failure.message)),
      (taxpayers) => emit(TaxpayersLoaded(taxpayers)),
    );
  }

  Future<void> _onRefreshTaxpayers(
    RefreshTaxpayers event,
    Emitter<TaxpayersState> emit,
  ) async {
    emit(TaxpayersRefreshing());

    final result = await getAllTaxpayersUseCase();

    result.fold(
      (failure) => emit(TaxpayersError(failure.message)),
      (taxpayers) => emit(TaxpayersLoaded(taxpayers)),
    );
  }
}

