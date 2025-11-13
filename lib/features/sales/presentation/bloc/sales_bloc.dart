import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/usecases/get_all_sales_usecase.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetAllSalesUseCase getAllSalesUseCase;

  SalesBloc({required this.getAllSalesUseCase}) : super(SalesInitial()) {
    on<LoadSales>(_onLoadSales);
    on<RefreshSales>(_onRefreshSales);
  }

  Future<void> _onLoadSales(
    LoadSales event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoading());

    final result = await getAllSalesUseCase();

    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (sales) => emit(SalesLoaded(sales)),
    );
  }

  Future<void> _onRefreshSales(
    RefreshSales event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesRefreshing());

    final result = await getAllSalesUseCase();

    result.fold(
      (failure) => emit(SalesError(failure.message)),
      (sales) => emit(SalesLoaded(sales)),
    );
  }
}

