import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/orders_models.dart';
import '../../domain/usecases/get_order_detail_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import 'order_detail_state.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit({
    required String orderId,
    required GetOrderDetailUseCase getOrderDetailUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
  }) : _orderId = orderId,
       _getOrderDetailUseCase = getOrderDetailUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       super(OrderDetailState.initial());

  final String _orderId;
  final GetOrderDetailUseCase _getOrderDetailUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final detail = await _getOrderDetailUseCase(_orderId);
      emit(state.copyWith(isLoading: false, detail: detail, clearError: true));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> reload() => load();

  Future<void> updateStatus(String status) async {
    emit(state.copyWith(isUpdating: true, clearError: true));

    try {
      final detail = await _updateOrderStatusUseCase(
        orderId: _orderId,
        status: status,
      );
      emit(state.copyWith(isUpdating: false, detail: detail, clearError: true));
    } catch (error) {
      emit(state.copyWith(isUpdating: false, errorMessage: _toMessage(error)));
    }
  }

  String _toMessage(Object error) {
    if (error is OrdersException) {
      return error.message;
    }
    return 'Failed to load order detail.';
  }
}
