import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/usecases/get_all_customers_usecase.dart';

part 'customers_event.dart';
part 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final GetAllCustomersUseCase getAllCustomersUseCase;

  CustomersBloc({required this.getAllCustomersUseCase})
      : super(CustomersInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<RefreshCustomers>(_onRefreshCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomersState> emit,
  ) async {
    emit(CustomersLoading());

    final result = await getAllCustomersUseCase();

    result.fold(
      (failure) => emit(CustomersError(failure.message)),
      (customers) => emit(CustomersLoaded(customers)),
    );
  }

  Future<void> _onRefreshCustomers(
    RefreshCustomers event,
    Emitter<CustomersState> emit,
  ) async {
    emit(CustomersRefreshing());

    final result = await getAllCustomersUseCase();

    result.fold(
      (failure) => emit(CustomersError(failure.message)),
      (customers) => emit(CustomersLoaded(customers)),
    );
  }
}

