part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class UnAuthenticated extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthSignedIn extends AuthState {
  @override
  List<Object?> get props => [];
}