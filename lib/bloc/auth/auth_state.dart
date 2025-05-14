part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class UnAuthenticated extends AuthState {
  final String errorMessage;
  UnAuthenticated({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthSignedIn extends AuthState {
  @override
  List<Object?> get props => [];
}