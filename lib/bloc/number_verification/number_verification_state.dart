part of 'number_verification_bloc.dart';

sealed class NumberVerificationState extends Equatable {
  const NumberVerificationState();
  
  @override
  List<Object?> get props => [];
}


// Number verification
class NumberVerificationInitial extends NumberVerificationState {}

class NumberVerificationDuringRegistrationInitial extends NumberVerificationState {}
class NumberVerificationAfterRegistrationInitial extends NumberVerificationState {}

class NumberSubmitInProgress extends NumberVerificationState {}

class NumberSubmitSuccess extends NumberVerificationState {
  final String verificationId;
  final int? resendToken;

  const NumberSubmitSuccess({required this.verificationId, required this.resendToken});

  @override
  List<Object?> get props => [verificationId, resendToken];
}

class NumberSubmitFailure extends NumberVerificationState {}

class NumberVerificationInProgress extends NumberVerificationState {}
class NumberVerificationSuccess extends NumberVerificationState {}
class NumberVerificationFailure extends NumberVerificationState {}

class NumberVerificationSkipped extends NumberVerificationState {}


// Checking if phone number is verified
class NumberCheckInProgress extends NumberVerificationState {}
class NumberCheckSuccess extends NumberVerificationState {}
class NumberCheckFailure extends NumberVerificationState {}
