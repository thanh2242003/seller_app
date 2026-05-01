import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/dashboard_models.dart';
import '../../domain/usecases/get_dashboard_usecase.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({required GetDashboardUseCase getDashboardUseCase})
    : _getDashboardUseCase = getDashboardUseCase,
      super(DashboardState.initial());

  final GetDashboardUseCase _getDashboardUseCase;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final metrics = await _getDashboardUseCase();
      emit(
        state.copyWith(isLoading: false, metrics: metrics, clearError: true),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: _toMessage(error)));
    }
  }

  Future<void> reload() => load();

  String _toMessage(Object error) {
    if (error is DashboardException) {
      return error.message;
    }
    return 'Failed to load dashboard data.';
  }
}
