import '../../data/models/orders_models.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetailUseCase {
  GetOrderDetailUseCase(this._repository);

  final OrdersRepository _repository;

  Future<OrderDetailModel> call(String orderId) {
    return _repository.getOrderDetail(orderId);
  }
}
