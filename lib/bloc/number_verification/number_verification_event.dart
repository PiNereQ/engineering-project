part of 'number_verification_bloc.dart';

abstract class NumberVerificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NumberVerificationFirstRequested extends NumberVerificationEvent {}

class NumberVerificationRequested extends NumberVerificationEvent {
  final String number;

  NumberVerificationRequested({required this.number});

  @override
  List<Object?> get props => [number];
}

class NumberVerificationCheckRequested extends NumberVerificationEvent {}

class NumberVerificationSkipRequested extends NumberVerificationEvent {}
