part of 'number_verification_bloc.dart';

sealed class NumberVerificationState extends Equatable {
  const NumberVerificationState();
  
  @override
  List<Object?> get props => [];
}


// Number verification
class NumberVerificationInitial extends NumberVerificationState {}

class NumberVerificationDuringRegistrationInitial extends NumberVerificationState {
  final String? phoneNumber;
  const NumberVerificationDuringRegistrationInitial({this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
class NumberVerificationAfterRegistrationInitial extends NumberVerificationState {
  final String? phoneNumber;
  const NumberVerificationAfterRegistrationInitial({this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class NumberSubmitInProgress extends NumberVerificationState {}

class NumberSubmitSuccess extends NumberVerificationState {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  const NumberSubmitSuccess({required this.phoneNumber, required this.verificationId, required this.resendToken});
  @override
  List<Object?> get props => [verificationId, resendToken];
}

class NumberSubmitFailure extends NumberVerificationState {
  final String? message;

  const NumberSubmitFailure({this.message});
  
  @override
  List<Object?> get props => [message];
}

class NumberVerificationInProgress extends NumberVerificationState {}
class NumberVerificationSuccess extends NumberVerificationState {}
class NumberVerificationFailure extends NumberVerificationState {}

class NumberVerificationSkipped extends NumberVerificationState {}

// Checking if phone number is verified
class NumberCheckInProgress extends NumberVerificationState {}
class NumberCheckSuccess extends NumberVerificationState {}
class NumberCheckFailure extends NumberVerificationState {}
