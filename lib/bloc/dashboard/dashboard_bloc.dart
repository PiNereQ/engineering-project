import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/dashboard_model.dart';
import 'package:proj_inz/data/repositories/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository dashboardRepository;

  DashboardBloc(this.dashboardRepository) : super(DashboardInitial()) {
    on<FetchDashboard>(_onFetchDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  Future<void> _onFetchDashboard(
    FetchDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final dashboard = await dashboardRepository.fetchDashboard();
      emit(DashboardLoaded(dashboard));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching dashboard: $e');
      }
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final dashboard = await dashboardRepository.fetchDashboard();
      emit(DashboardLoaded(dashboard));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error refreshing dashboard: $e');
      }
      emit(DashboardError(e.toString()));
    }
  }
}
