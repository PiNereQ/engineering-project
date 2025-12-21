import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/bloc/listed_coupon_list/listed_coupon_list_bloc.dart';
import 'package:proj_inz/bloc/listed_coupon_list/listed_coupon_list_event.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/data/repositories/user_repository.dart';
import 'package:proj_inz/presentation/screens/bought_coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/debug_screen.dart';
import 'package:proj_inz/presentation/screens/listed_coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/settings_screen.dart';
import 'package:proj_inz/presentation/screens/sign_in_screen.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/reputation_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

  class _ProfileScreenState extends State<ProfileScreen> {
    int? reputation;
    String? username;
    bool isLoadingProfile = true;

    late final UserRepository _userRepository;

    @override
    void initState() {
      super.initState();
      _userRepository = context.read<UserRepository>();
      _loadUserProfile();
    }

    Future<void> _loadUserProfile() async {
      final userId = await _userRepository.getCurrentUserId();
      if (userId == null) {
        setState(() {
          isLoadingProfile = false;
        });
        return;
      }

      final profile = await _userRepository.getUserProfile(userId);

      setState(() {
        reputation = profile?['reputation'] ?? 0;
        username = profile?['username'] ?? 'User';
        isLoadingProfile = false;
      });
    }

@override
Widget build(BuildContext context) {
  return BlocConsumer<AuthBloc, AuthState>(
    listener: (context, state) {
      if (state is AuthUnauthenticated) {
        showCustomSnackBar(context, "Wylogowano pomyślnie");

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    },
    builder: (context, state) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Row(
                  spacing: 12,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset(
                        'assets/icons/Awatar.svg',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    Text(
                      isLoadingProfile
                          ? 'Cześć!'
                          : 'Cześć, ${username ?? ''}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                // Reputacja
                Column(
                  spacing: 16,
                  children: [
                    const Row(
                      spacing: 12,
                      children: [
                        Icon(Icons.speed_rounded, size: 28),
                        Text(
                          'Reputacja',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    if (isLoadingProfile)
                      const CircularProgressIndicator()
                    else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ReputationBar(
                        value: reputation ?? 0,
                      ),
                    ),
                  ],
                ),
                // Twoje kupony
                Column(
                  spacing: 16,
                  children: [
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 12,
                      children: [
                        Icon(Icons.confirmation_number_outlined, size: 28),
                        Text(
                          'Twoje kupony',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 20,
                      children: [
                        Expanded(
                          child: CustomTextButton(
                            label: 'Kupione',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const BoughtCouponListScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: CustomTextButton(
                            label: 'Wystawione',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider(
                                    create: (context) => ListedCouponListBloc(
                                      context.read<CouponRepository>(),
                                    )..add(
                                        FetchListedCoupons(
                                          userId: FirebaseAuth.instance.currentUser!.uid,
                                        ),
                                      ),
                                    child: const ListedCouponListScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    CustomTextButton(
                      width: double.infinity,
                      label: 'Zapisane',
                      onTap: () {},
                    ),
                  ],
                ),
                // Preferencje
                Column(
                  spacing: 16,
                  children: [
                    const Row(
                      spacing: 12,
                      children: [
                        Icon(Icons.favorite_outline_rounded, size: 28),
                        Text(
                          'Twoje preferencje',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    CustomTextButton(
                      width: double.infinity,
                      label: 'Ulubione',
                      onTap: () {},
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: DashedSeparator(),
                ),

                Row(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: CustomTextButton(
                        label: 'Ustawienia',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: CustomTextButton(
                        label: 'Wyloguj',
                        backgroundColor: AppColors.alertButton,
                        onTap: () {
                          context.read<AuthBloc>().add(SignOutRequested());
                        },
                      ),
                    ),
                  ],
                ),

                if (kDebugMode)
                  CustomTextButton(
                    width: double.infinity,
                    label: 'Debug',
                    icon: const Icon(Icons.developer_mode_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DebugScreen(),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      );
    },
  );
}
}