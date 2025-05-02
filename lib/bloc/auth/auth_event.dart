part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable{
  @override
  List<Object?> get props => [];
}


class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;

  SignUpRequested({required this.email, required this.password, required this.confirmPassword});

  @override
  List<Object?> get props => [email, password, confirmPassword];
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {
  @override
  List<Object?> get props => [];
}