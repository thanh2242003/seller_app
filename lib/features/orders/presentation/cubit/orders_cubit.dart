import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/orders_models.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({required GetOrdersUseCase getOrdersUseCase})
    : _getOrdersUseCase = getOrdersUseCase,
      super(OrdersState.initial());

  final GetOrdersUseCase _getOrdersUseCase;

  Future<void> load({String? status}) async {
    final selectedStatus = status ?? state.selectedStatus;
    emit(
      state.copyWith(
        selectedStatus: selectedStatus,
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final result = await _getOrdersUseCase(status: selectedStatus);
      emit(
        state.copyWith(
          selectedStatus: selectedStatus,
          isLoading: false,
          result: result,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          selectedStatus: selectedStatus,
          isLoading: false,
          errorMessage: _toMessage(error),
        ),
      );
    }
  }

  Future<void> changeStatus(String status) => load(status: status);

  Future<void> reload() => load();

  String _toMessage(Object error) {
    if (error is OrdersException) {
      return error.message;
    }
    return 'Failed to load orders.';
  }
}
