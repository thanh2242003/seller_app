import '../../data/models/dashboard_models.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardUseCase {
  GetDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  Future<DashboardMetricsModel> call() {
    return _repository.getDashboard();
  }
}
