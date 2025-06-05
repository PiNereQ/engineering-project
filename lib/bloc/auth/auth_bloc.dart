import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/data/repositories/auth_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthBloc({required this.authRepository, required this.userRepository}) : super(UnAuthenticated(errorMessage: '')) {
    on<SignUpRequested>(_onSignUp);
    on<SignInRequested>(_onSignIn);
    on<SignOutRequested>(_onSignOut);
  }
  void _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.singUp(
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await userRepository.createUserProfile(
          uid: user.uid,
          email: user.email ?? event.email,
        );
      }

      emit(AuthSignedIn());
    } catch (e) {
      emit(UnAuthenticated(errorMessage: e.toString()));
    }
  }


  void _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signIn(event.email, event.password);
      emit(AuthSignedIn());
    } catch (e) {
      emit(UnAuthenticated(errorMessage: e.toString()));
    }
 }

  void _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(UnAuthenticated(errorMessage: 'Signed out successfully'));
    } catch (e) {
      emit(UnAuthenticated(errorMessage: e.toString()));
    }
  }
}