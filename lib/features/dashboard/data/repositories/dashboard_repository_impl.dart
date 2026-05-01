import '../models/dashboard_models.dart';
import '../sources/dashboard_remote_data_source.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({DashboardRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? DashboardRemoteDataSource();

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<DashboardMetricsModel> getDashboard() {
    return _remoteDataSource.getDashboard();
  }
}
