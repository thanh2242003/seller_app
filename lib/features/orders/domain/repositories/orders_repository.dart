import '../../data/models/orders_models.dart';

abstract class OrdersRepository {
  Future<OrdersResultModel> getOrders({int page, int limit, String? status});

  Future<OrderDetailModel> getOrderDetail(String orderId);

  Future<OrderDetailModel> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
