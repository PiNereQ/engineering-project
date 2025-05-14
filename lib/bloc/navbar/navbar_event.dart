import 'package:equatable/equatable.dart';

abstract class NavbarEvent extends Equatable {
  const NavbarEvent();

  @override
  List<Object> get props => [];
}

class NavbarItemSelected extends NavbarEvent {
  final int index;

  const NavbarItemSelected(this.index);

  @override
  List<Object> get props => [index];
}
