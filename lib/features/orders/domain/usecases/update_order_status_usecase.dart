import '../../data/models/orders_models.dart';
import '../repositories/orders_repository.dart';

class UpdateOrderStatusUseCase {
  UpdateOrderStatusUseCase(this._repository);

  final OrdersRepository _repository;

  Future<OrderDetailModel> call({
    required String orderId,
    required String status,
  }) {
    return _repository.updateOrderStatus(orderId: orderId, status: status);
  }
}
