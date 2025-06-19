part of 'number_verification_bloc.dart';

sealed class NumberVerificationState extends Equatable {
  const NumberVerificationState();
  
  @override
  List<Object> get props => [];
}

class NumberVerificationInitial extends NumberVerificationState {}

class NumberVerificationAfterRegistration extends NumberVerificationState {}

class NumberVerificationInProgress extends NumberVerificationState {}

class NumberVerificationSuccess extends NumberVerificationState {}

class NumberVerificationFailure extends NumberVerificationState {}

class NumberVerificationCheckInProgress extends NumberVerificationState {}

class NumberVerificationCheckSuccess extends NumberVerificationState {}

class NumberVerificationCheckFailure extends NumberVerificationState {}

class NumberVerificationSkip extends NumberVerificationState {}