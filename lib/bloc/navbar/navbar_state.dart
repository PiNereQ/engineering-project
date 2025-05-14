import 'package:equatable/equatable.dart';

class NavbarState extends Equatable {
  final int selectedIndex;

  const NavbarState(this.selectedIndex);

  @override
  List<Object> get props => [selectedIndex];
}
