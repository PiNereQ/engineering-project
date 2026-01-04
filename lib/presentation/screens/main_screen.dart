import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/bloc/navbar/navbar_bloc.dart';
import 'package:proj_inz/bloc/navbar/navbar_state.dart';
import 'package:proj_inz/bloc/number_verification/number_verification_bloc.dart';
import 'package:proj_inz/bloc/chat/unread/chat_unread_bloc.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_bloc.dart';
import 'package:proj_inz/bloc/chat/list/chat_list_event.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/presentation/screens/chat_screen.dart';
import 'package:proj_inz/presentation/screens/coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/home_screen.dart';
import 'package:proj_inz/presentation/screens/phone_number_confirmation_screen.dart';
import 'package:proj_inz/presentation/screens/profile_screen.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/navbar/navbar.dart';
import 'package:proj_inz/data/repositories/fcm_repository.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final FcmRepository _fcmRepository;

  Future<void> _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Permission: ${settings.authorizationStatus}');
  }

  @override
  void initState() {
    super.initState();
    _fcmRepository = FcmRepository(userRepository: context.read<UserRepository>());
    Future.microtask(() async {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (mounted) context.read<ChatListBloc>().add(LoadBuyingConversations(userId: userId));
      if (mounted) context.read<ChatUnreadBloc>().add(CheckUnreadStatus(userId: userId));
      if (userId.isNotEmpty) {
        await _requestPermission();
        await _fcmRepository.initFcmTokenManagement();
      }
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
            if (state is NumberVerificationDuringRegistrationInitial) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PhoneNumberConfirmationScreen(),
                ),
              );
            });
          }

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
