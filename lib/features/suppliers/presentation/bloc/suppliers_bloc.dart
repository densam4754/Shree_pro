import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/supplier_entity.dart';
import '../../domain/usecases/get_all_suppliers_usecase.dart';

part 'suppliers_event.dart';
part 'suppliers_state.dart';

class SuppliersBloc extends Bloc<SuppliersEvent, SuppliersState> {
  final GetAllSuppliersUseCase getAllSuppliersUseCase;

  SuppliersBloc({required this.getAllSuppliersUseCase})
      : super(SuppliersInitial()) {
    on<LoadSuppliers>(_onLoadSuppliers);
    on<RefreshSuppliers>(_onRefreshSuppliers);
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliers event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(SuppliersLoading());

    final result = await getAllSuppliersUseCase();

    result.fold(
      (failure) => emit(SuppliersError(failure.message)),
      (suppliers) => emit(SuppliersLoaded(suppliers)),
    );
  }

  Future<void> _onRefreshSuppliers(
    RefreshSuppliers event,
    Emitter<SuppliersState> emit,
  ) async {
    emit(SuppliersRefreshing());

    final result = await getAllSuppliersUseCase();

    result.fold(
      (failure) => emit(SuppliersError(failure.message)),
      (suppliers) => emit(SuppliersLoaded(suppliers)),
    );
  }
}

