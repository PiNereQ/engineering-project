part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthUnauthenticated extends AuthState {}

// Sign-in

class AuthSignInInProgress extends AuthState {}

class AuthSignInSuccess extends AuthState {}

class AuthSignInFailure extends AuthState {
  final String errorMessage;
  AuthSignInFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// Sign-up

class AuthSignUpInProgress extends AuthState {}

class AuthSignUpSuccess extends AuthState {}

class AuthSignUpFailure extends AuthState {
  final String errorMessage;
  AuthSignUpFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// Sign-out

class AuthSignOutInProgress extends AuthState {}

// handled by AuthUnauthenticated
// class AuthSignOutSuccess extends AuthState {}

class AuthSignOutFailure extends AuthState {
  final String errorMessage;
  AuthSignOutFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// Password reset

class AuthPasswordResetInProgress extends AuthState {}

class AuthPasswordResetSuccess extends AuthState {}

class AuthPasswordResetFailure extends AuthState {
  final String errorMessage;
  AuthPasswordResetFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

// class UnAuthenticated extends AuthState {
//   final String errorMessage;
//   UnAuthenticated({required this.errorMessage});

//   @override
//   List<Object?> get props => [errorMessage];
// }


