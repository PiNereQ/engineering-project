part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}
