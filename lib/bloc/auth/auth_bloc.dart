import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(UnAuthenticated()) {
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
      );
      emit(AuthSignedIn());
    } catch (e) {
      emit(UnAuthenticated());
    }
  }


  void _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signIn(event.email, event.password);
      emit(AuthSignedIn());
    } catch (e) {
      emit(UnAuthenticated());
    }
 }

  void _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(UnAuthenticated());
    } catch (e) {
      emit(UnAuthenticated());
    }
  }
}