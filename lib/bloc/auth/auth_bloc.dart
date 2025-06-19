import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/data/repositories/auth_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthBloc({required this.authRepository, required this.userRepository})
    : super(AuthUnauthenticated()) {
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthSignUpInProgress());
    try {
      final userCredential = await authRepository.singUp(
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      final user = userCredential.user;

      // try {
      //   add(SignInRequested(email: event.email, password: event.password));
      // } catch (e) {
      //   emit(AuthSignInFailure(errorMessage: e.toString()));
      //   return;
      // } finally {
        if (user != null) {
          await userRepository.createUserProfile(
            uid: user.uid,
            email: user.email ?? event.email,
          );
        }
      // }

      emit(AuthSignUpSuccess());
    } catch (e) {
      emit(AuthSignUpFailure(errorMessage: e.toString()));
    }
  }


  void _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthSignInInProgress());
    try {
      await authRepository.signIn(event.email, event.password);
      emit(AuthSignInSuccess());
    } catch (e) {
      emit(AuthSignInFailure(errorMessage: e.toString()));
    }
 }

  void _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthSignOutInProgress());
    try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthSignOutFailure(errorMessage: e.toString()));
    }
  }
}