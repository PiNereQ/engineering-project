part of 'dashboard_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

/// State when refreshing - keeps old data visible while loading
class DashboardRefreshing extends DashboardState {
  final Dashboard dashboard;

  const DashboardRefreshing(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

class DashboardLoaded extends DashboardState {
  final Dashboard dashboard;

  const DashboardLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
