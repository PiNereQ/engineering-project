import 'package:flutter_bloc/flutter_bloc.dart';

import 'navbar_event.dart';
import 'navbar_state.dart';

class NavbarBloc extends Bloc<NavbarEvent, NavbarState> {
  NavbarBloc() : super(const NavbarState(0)) {
    on<NavbarItemSelected>((event, emit) {
      emit(NavbarState(event.index));
    });
  }
}
