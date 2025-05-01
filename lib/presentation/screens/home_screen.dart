import 'package:flutter/material.dart';
import 'package:proj_inz/presentation/screens/add_screen.dart';
import 'package:proj_inz/presentation/screens/chats_screen.dart';
import 'package:proj_inz/presentation/screens/coupons_screen.dart';
import 'package:proj_inz/presentation/screens/map_screen.dart';
import 'package:proj_inz/presentation/screens/profile_screen.dart';
import 'package:proj_inz/presentation/widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    Center(child: CouponsScreen()),
    Center(child: MapScreen()),
    Center(child: AddScreen()),
    Center(child: ChatScreen()),
    Center(child: ProfileScreen()),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavBar(
        screens: [_screens[0], _screens[1], _screens[2], _screens[3], _screens[4]],
      ),
    );
  }
}
