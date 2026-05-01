import '../../data/models/orders_models.dart';
import '../repositories/orders_repository.dart';

class GetOrdersUseCase {
  GetOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<OrdersResultModel> call({
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return _repository.getOrders(page: page, limit: limit, status: status);
  }
}
