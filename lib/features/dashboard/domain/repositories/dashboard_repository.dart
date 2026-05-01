import '../../data/models/dashboard_models.dart';

abstract class DashboardRepository {
  Future<DashboardMetricsModel> getDashboard();
}
