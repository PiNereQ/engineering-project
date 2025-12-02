import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/bloc/auth/auth_bloc.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/screens/bought_coupon_list_screen.dart';
import 'package:proj_inz/presentation/screens/debug_screen.dart';
import 'package:proj_inz/presentation/screens/sign_in_screen.dart';
import 'package:proj_inz/presentation/widgets/custom_snack_bar.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/ticket_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                      const Text(
                        'Cześć, username',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Itim',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  TicketButton(
                    label: 'Twoje punkty',
                    value: '997',
                    icon: const Icon(Icons.favorite),
                    onTap: () {},
                  ),
                  // Reputacja
                  const Column(
                    spacing: 16,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                      Placeholder(fallbackHeight: 16)
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
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 20,
                        children: [
                          Expanded(
                            child: CustomTextButton(
                              label: 'Kupione',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const BoughtCouponListScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: CustomTextButton(
                              label: 'Wystawione',
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      CustomTextButton(
                        width: double.infinity,
                        label: 'Obserwowane',
                        onTap: () {},
                      ),
                    ],
                  ),
                  // Twoje preferencje
                  Column(
                    spacing: 16,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                  // Ranking
                  Column(
                    spacing: 16,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 12,
                        children: [
                          Icon(Icons.leaderboard_outlined, size: 28),
                          Text(
                            'Ranking',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Itim',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      TicketButton(
                        label: 'Twoja pozycja',
                        value: '3. miejsce',
                        icon: const Icon(Icons.favorite),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const Divider(
                    color: AppColors.textPrimary,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20,
                    children: [
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child: CustomTextButton(
                          label: 'Ustawienia',
                          onTap: () {},
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
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
                            builder: (context) => const DebugScreen(),
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 64), // padding for navbar
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
