import '../../data/models/dashboard_models.dart';

class DashboardState {
  const DashboardState({
    required this.isLoading,
    this.errorMessage,
    this.metrics,
  });

  final bool isLoading;
  final String? errorMessage;
  final DashboardMetricsModel? metrics;

  factory DashboardState.initial() {
    return const DashboardState(isLoading: false);
  }

  DashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    DashboardMetricsModel? metrics,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      metrics: metrics ?? this.metrics,
    );
  }
}
