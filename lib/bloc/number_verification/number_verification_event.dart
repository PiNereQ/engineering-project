
part of 'number_verification_bloc.dart';

class ResendCountdownTicked extends NumberVerificationEvent {
  final int secondsLeft;
  final String verificationId;
  final int? resendToken;

  ResendCountdownTicked({required this.secondsLeft, required this.verificationId, required this.resendToken});

  @override
  List<Object?> get props => [secondsLeft, verificationId, resendToken];
}

class ResendCodeRequested extends NumberVerificationEvent {
  final String phoneNumber;
  final int? resendToken;

  ResendCodeRequested({required this.phoneNumber, this.resendToken});

  @override
  List<Object?> get props => [phoneNumber, resendToken];
}

abstract class NumberVerificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NumberVerificationFormShownDuringRegistration extends NumberVerificationEvent {
  final String? phoneNumber;
  NumberVerificationFormShownDuringRegistration({this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class NumberVerificationFormShownAfterRegistration extends NumberVerificationEvent {
  final String? phoneNumber;
  NumberVerificationFormShownAfterRegistration({this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class NumberVerificationSkipRequested extends NumberVerificationEvent {}

class NumberVerificationRequested extends NumberVerificationEvent {
  final String number;

  NumberVerificationRequested({required this.number});

  @override
  List<Object?> get props => [number];
}

class PhoneNumberCodeSent extends NumberVerificationEvent {
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;

  PhoneNumberCodeSent({required this.phoneNumber, required this.verificationId, required this.resendToken});

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


class NumberVerificationReturnToPhoneNumberStep extends NumberVerificationEvent {
  final String phoneNumber;
  NumberVerificationReturnToPhoneNumberStep({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}