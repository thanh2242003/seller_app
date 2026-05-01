import '../../data/models/orders_models.dart';

class OrderDetailState {
  const OrderDetailState({
    required this.isLoading,
    required this.isUpdating,
    this.errorMessage,
    this.detail,
  });

  final bool isLoading;
  final bool isUpdating;
  final String? errorMessage;
  final OrderDetailModel? detail;

  factory OrderDetailState.initial() {
    return const OrderDetailState(isLoading: false, isUpdating: false);
  }

  OrderDetailState copyWith({
    bool? isLoading,
    bool? isUpdating,
    String? errorMessage,
    bool clearError = false,
    OrderDetailModel? detail,
  }) {
    return OrderDetailState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      detail: detail ?? this.detail,
    );
  }
}
