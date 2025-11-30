import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/bloc/navbar/navbar_bloc.dart';
import 'package:proj_inz/bloc/navbar/navbar_state.dart';
import 'package:proj_inz/bloc/number_verification/number_verification_bloc.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_bloc.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_event.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_bloc.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_event.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/screens/chat_screen.dart';
import 'package:proj_inz/presentation/screens/coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/home_screen.dart';
import 'package:proj_inz/presentation/screens/phone_number_confirmation_screen.dart';
import 'package:proj_inz/presentation/screens/profile_screen.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/navbar/navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();

    // late initialization to ensure context is available, load conversations, check unread messages
    Future.microtask(() {
      context.read<ChatListBloc>().add(LoadBuyingConversations());
      context.read<ChatUnreadBloc>().add(CheckUnreadStatus());
    });
  }

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    CouponListScreen(),
    Placeholder(), // makes indexes check out
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavbarBloc()),
        BlocProvider(
          create: (context) => CouponListBloc(context.read<CouponRepository>()),
        ),
      ],
      child: BlocBuilder<NumberVerificationBloc, NumberVerificationState>(
        builder: (context, state) {
          if (state is NumberVerificationAfterRegistration) return const PhoneNumberConfirmationScreen();

          return BlocBuilder<NavbarBloc, NavbarState>(
            builder: (context, state) {
              return Scaffold(
                backgroundColor: AppColors.surface,
                body: SafeArea(
                  child: Stack(
                    children: [
                      _screens[state.selectedIndex],
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 16.0,
                          ),
                          child: const Navbar(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
