import '../models/orders_models.dart';
import '../sources/orders_remote_data_source.dart';
import '../../domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl({OrdersRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? OrdersRemoteDataSource();

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Future<OrdersResultModel> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
  }) {
    return _remoteDataSource.getOrders(
      page: page,
      limit: limit,
      status: status,
    );
  }

  @override
  Future<OrderDetailModel> getOrderDetail(String orderId) {
    return _remoteDataSource.getOrderDetail(orderId);
  }

  @override
  Future<OrderDetailModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    return _remoteDataSource.updateOrderStatus(
      orderId: orderId,
      status: status,
    );
  }
}
