part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable{
  @override
  List<Object?> get props => [];
}


class SingUpRequested extends AuthEvent {
  final String email;
  final String password;

  SingUpRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
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