import '../../data/models/orders_models.dart';

class OrdersState {
  const OrdersState({
    required this.selectedStatus,
    required this.isLoading,
    this.errorMessage,
    this.result,
  });

  final String selectedStatus;
  final bool isLoading;
  final String? errorMessage;
  final OrdersResultModel? result;

  factory OrdersState.initial() {
    return const OrdersState(selectedStatus: 'all', isLoading: false);
  }

  OrdersState copyWith({
    String? selectedStatus,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    OrdersResultModel? result,
  }) {
    return OrdersState(
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: result ?? this.result,
    );
  }
}
