import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';


part 'number_verification_event.dart';
part 'number_verification_state.dart';

class NumberVerificationBloc extends Bloc<NumberVerificationEvent, NumberVerificationState> {
    final UserRepository userRepository;

  NumberVerificationBloc({required this.userRepository}) : super(NumberVerificationInitial()) {
    on<NumberVerificationFormShownDuringRegistration>((event, emit) async {
      if(kDebugMode) print('[NumberVerificationBloc] Showing number verification form during registration');
      emit(NumberVerificationDuringRegistrationInitial(phoneNumber:  event.phoneNumber));
    });

    on<NumberVerificationFormShownAfterRegistration>((event, emit) async {
     if(kDebugMode)  print('[NumberVerificationBloc] Showing number verification form after registration');
      emit(NumberVerificationAfterRegistrationInitial(phoneNumber: event.phoneNumber));
    });

    on<NumberVerificationSkipRequested>((event, emit) async {
      emit(NumberVerificationSkipped());
    });

    on<NumberVerificationRequested>((event, emit) async {
      if(kDebugMode) print('[NumberVerificationBloc] Starting phone number verification for ${event.number}');
      emit(NumberSubmitInProgress());  

      try {
        // Check if phone number is already in use via API
        final response = await userRepository.isPhoneNumberUsed(event.number);
        if (response) {
          if (kDebugMode) print('[NumberVerificationBloc] Phone number ${event.number} is already in use.');
          emit(NumberSubmitFailure(message: 'Numer telefonu jest już używany.'));
          return;
        }
      } catch (e) {
        if (kDebugMode) print('[NumberVerificationBloc] Error checking phone number usage: $e');
        emit(NumberSubmitFailure(message: 'Wystąpił błąd podczas sprawdzania numeru telefonu.'));
        return;
      }

      try {
        if(kDebugMode) print('[NumberVerificationBloc] Calling Firebase verifyPhoneNumber for ${event.number}');
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: event.number,
          verificationCompleted: (PhoneAuthCredential credential) async {
            add(PhoneNumberVerificationCompleted());
          },
          verificationFailed: (FirebaseAuthException e) {
            if (kDebugMode) print('[NumberVerificationBloc] Phone number verification failed: ${e.message}');
            emit(NumberSubmitFailure());
          },
          codeSent: (String verificationId, int? resendToken) async {
            if (kDebugMode) print('[NumberVerificationBloc] Code sent with verificationId: $verificationId');
            add(
              PhoneNumberCodeSent(
                phoneNumber: event.number,
                verificationId: verificationId,
                resendToken: resendToken,
              ),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } on Exception catch (e) {
        if (kDebugMode) print('[NumberVerificationBloc] Error during phone number verification: $e');
        emit(NumberSubmitFailure(message: 'Wystąpił błąd podczas weryfikacji numeru telefonu.'));
      }
    });

    on<PhoneNumberCodeSent>((event, emit) async {
      if(kDebugMode) print('[NumberVerificationBloc] Emitting CodeSentState with verificationId: ${event.verificationId}');

      emit(NumberSubmitSuccess(phoneNumber: event.phoneNumber, verificationId: event.verificationId, resendToken: event.resendToken));
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

        // Add phone number to user in API
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && user.phoneNumber != null) {
          await userRepository.addPhoneNumberToUser(uid: user.uid, phoneNumber: user.phoneNumber!);
        }

        emit(NumberVerificationSuccess());
      } catch (e) {
        emit(NumberVerificationFailure());
      }
    });

    on<PhoneNumberVerificationCompleted>((event, emit) async {
      if(kDebugMode) print('[NumberVerificationBloc] Emitting PhoneNumberVerificationSuccess');
      emit(NumberVerificationSuccess());
    });


  }
}
