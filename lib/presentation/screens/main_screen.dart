import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/navbar/navbar_bloc.dart';
import 'package:proj_inz/bloc/navbar/navbar_event.dart';
import 'package:proj_inz/bloc/navbar/navbar_state.dart';
import 'package:proj_inz/presentation/screens/add_screen.dart';
import 'package:proj_inz/presentation/screens/chat_screen.dart';
import 'package:proj_inz/presentation/screens/coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/home_screen.dart';
import 'package:proj_inz/presentation/screens/profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    CouponsScreen(),
    Placeholder(), // makes indexes check out
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavbarBloc(),
      child: Scaffold(
        body: BlocBuilder<NavbarBloc, NavbarState>(
          builder: (context, state) {
            return _screens[state.selectedIndex];
          },
        ),
        bottomNavigationBar: BlocBuilder<NavbarBloc, NavbarState>(
          builder: (context, state) {
            return BottomNavigationBar(
              currentIndex: state.selectedIndex,
              onTap: (index) {
                if (index == 2) {
                  // makes back button in AddScreen work properly
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddScreen()),
                  );
                } else {
                  context.read<NavbarBloc>().add(NavbarItemSelected(index));
                }
              },
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: 'Coupons'),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            );
          },
        ),
      ),
    );
  }
}
