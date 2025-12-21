import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

part 'number_verification_event.dart';
part 'number_verification_state.dart';

class NumberVerificationBloc extends Bloc<NumberVerificationEvent, NumberVerificationState> {
  NumberVerificationBloc() : super(NumberVerificationInitial()) {
    on<NumberVerificationFormShownDuringRegistration>((event, emit) async {
      emit(NumberVerificationDuringRegistrationInitial());
    });

    on<NumberVerificationFormShownAfterRegistration>((event, emit) async {
      emit(NumberVerificationAfterRegistrationInitial());
    });

    on<NumberVerificationSkipRequested>((event, emit) async {
      emit(NumberVerificationSkipped());
    });

    on<NumberVerificationRequested>((event, emit) async {
      if(kDebugMode) print('Starting phone number verification for ${event.number}');
      emit(NumberSubmitInProgress());

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: event.number,
        verificationCompleted: (PhoneAuthCredential credential) async {
          add(PhoneNumberVerificationCompleted());
        },
        verificationFailed: (FirebaseAuthException e) {
          // TODO: handle error codes
          emit(NumberSubmitFailure());
        },
        codeSent: (String verificationId, int? resendToken) async {
          if(kDebugMode) print('Code sent with verificationId: $verificationId');
          add(PhoneNumberCodeSent(verificationId: verificationId, resendToken: resendToken));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    });

    on<PhoneNumberCodeSent>((event, emit) async {
      if(kDebugMode) print('Emitting NumberSubmitSuccess with verificationId: ${event.verificationId}');
      emit(NumberSubmitSuccess(verificationId: event.verificationId, resendToken: event.resendToken));
    });    

    on<ConfirmationCodeSubmitted>((event, emit) async {
      emit(NumberVerificationInProgress());
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: event.verificationId,
          smsCode: event.smsCode,
        );

        // Link the credential to the current user
        await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);

        emit(NumberVerificationSuccess());
      } catch (e) {
        emit(NumberVerificationFailure());
      }
    });

    on<PhoneNumberVerificationCompleted>((event, emit) async {
      if(kDebugMode) print('Emitting PhoneNumberVerificationSuccess');
      emit(NumberVerificationSuccess());
    });


  }
}
