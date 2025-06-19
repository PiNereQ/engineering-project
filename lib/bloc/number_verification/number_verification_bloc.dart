import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'number_verification_event.dart';
part 'number_verification_state.dart';

class NumberVerificationBloc extends Bloc<NumberVerificationEvent, NumberVerificationState> {
  NumberVerificationBloc() : super(NumberVerificationInitial()) {
    on<NumberVerificationFirstRequested>(_onNumberVerificationFirstRequested);
    on<NumberVerificationRequested>(_onNumberVerificationRequested);
    on<NumberVerificationSkipRequested>(_onNumberVerificationSkipped);
  }

  void _onNumberVerificationFirstRequested(NumberVerificationFirstRequested event, Emitter<NumberVerificationState> emit) async {
    emit(NumberVerificationAfterRegistration());
  }

  void _onNumberVerificationRequested(NumberVerificationRequested event, Emitter<NumberVerificationState> emit) async {
    throw UnimplementedError();
  }

  void _onNumberVerificationSkipped(NumberVerificationSkipRequested event, Emitter<NumberVerificationState> emit) async {
    emit(NumberVerificationSkip());
  }
}
