import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/usecases/get_all_purchases_usecase.dart';

part 'purchases_event.dart';
part 'purchases_state.dart';

class PurchasesBloc extends Bloc<PurchasesEvent, PurchasesState> {
  final GetAllPurchasesUseCase getAllPurchasesUseCase;

  PurchasesBloc({required this.getAllPurchasesUseCase})
      : super(PurchasesInitial()) {
    on<LoadPurchases>(_onLoadPurchases);
    on<RefreshPurchases>(_onRefreshPurchases);
  }

  Future<void> _onLoadPurchases(
    LoadPurchases event,
    Emitter<PurchasesState> emit,
  ) async {
    emit(PurchasesLoading());

    final result = await getAllPurchasesUseCase();

    result.fold(
      (failure) => emit(PurchasesError(failure.message)),
      (purchases) => emit(PurchasesLoaded(purchases)),
    );
  }

  Future<void> _onRefreshPurchases(
    RefreshPurchases event,
    Emitter<PurchasesState> emit,
  ) async {
    emit(PurchasesRefreshing());

    final result = await getAllPurchasesUseCase();

    result.fold(
      (failure) => emit(PurchasesError(failure.message)),
      (purchases) => emit(PurchasesLoaded(purchases)),
    );
  }
}

