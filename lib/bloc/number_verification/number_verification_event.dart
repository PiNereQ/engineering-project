part of 'number_verification_bloc.dart';

abstract class NumberVerificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NumberVerificationFormShownDuringRegistration extends NumberVerificationEvent {}

class NumberVerificationFormShownAfterRegistration extends NumberVerificationEvent {}

class NumberVerificationSkipRequested extends NumberVerificationEvent {}

class NumberVerificationRequested extends NumberVerificationEvent {
  final String number;

  NumberVerificationRequested({required this.number});

  @override
  List<Object?> get props => [number];
}

class PhoneNumberCodeSent extends NumberVerificationEvent {
  final String verificationId;
  final int? resendToken;

  PhoneNumberCodeSent({required this.verificationId, required this.resendToken});

  @override
  List<Object?> get props => [verificationId, resendToken];
}

class ConfirmationCodeSubmitted extends NumberVerificationEvent {
  final String verificationId;
  final String smsCode;

  ConfirmationCodeSubmitted({required this.verificationId, required this.smsCode});

  @override
  List<Object?> get props => [verificationId, smsCode];
}

class PhoneNumberVerificationCompleted extends NumberVerificationEvent {}

class NumberVerificationCheckRequested extends NumberVerificationEvent {}


